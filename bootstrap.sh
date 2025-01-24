#!/bin/sh

set -e

if [ "$#" -ne 3 ]; then
  echo "Usage: bootstrap.sh <github_account> <github_repo> <labels>" >&2
  exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
  echo "!! ERROR: Please run as root." >&2
  exit 1
fi

if [ -z "${PERSONAL_ACCESS_TOKEN}" ]; then
  echo "!! ERROR: Please set PERSONAL_ACCESS_TOKEN environment variable." >&2
  exit 1
fi

PYTHON_TARGET=${PYTHON_TARGET:-$(which python3)}
echo ">> Using PYTHON_TARGET=${PYTHON_TARGET}"

GITHUB_ACCOUNT=$1
GITHUB_REPO=$2
RUNNER_LABELS=$3
TARGET_DIR=${TARGET_DIR:-/opt/github-runner-install}
RUNNER_STATE=${RUNNER_STATE:-present}
RUNNER_USER=${RUNNER_USER:-root}
ANSIBLE_GITHUB_ACTIONS_RUNNER_VERSION=${ANSIBLE_GITHUB_ACTIONS_RUNNER_VERSION:-1.25.0}

echo ">> Installing ansible env in ${TARGET_DIR}"
mkdir -p ${TARGET_DIR}
cd ${TARGET_DIR}

cat <<EOF > requirements.yml
roles:
  - name: monolithprojects.github_actions_runner
    version: $ANSIBLE_GITHUB_ACTIONS_RUNNER_VERSION
    src: https://github.com/MonolithProjects/ansible-github_actions_runner
EOF

cat <<EOF > playbook.yml
---
- name: Install GitHub Actions Runner
  hosts: localhost
  user: root
  vars:
    - runner_state: "${RUNNER_STATE}"
    - runner_user: ${RUNNER_USER}
    - github_account: ${GITHUB_ACCOUNT}
    - github_repo: ${GITHUB_REPO}
    - access_token: "{{ lookup('env', 'PERSONAL_ACCESS_TOKEN') }}"
    - runner_labels:
$(
    for i in $RUNNER_LABELS; do
        echo "      - $i";
    done
)
  roles:
    - role: monolithprojects.github_actions_runner
EOF

${PYTHON_TARGET} -m venv venv
source ./venv/bin/activate
pip install -U pip
pip install ansible
ansible-galaxy install -r requirements.yml
ansible-playbook --inventory 127.1 playbook.yml
