# github-runner-bootstrap
Ansible playbooks, scripts, etc. for bootstrapping a github runner on host

## Usage
Make a (classic) personal access token with full repo permissions. Set and
export the `PERSONAL_ACCESS_TOKEN` variable with the token value.

Clone the repo and run the script as root with the following args:

- github account (ie org or user)
- github repo
- runner labels (supports multiple labels space-separated)

For example:

```
$ sudo -i
$ git clone https://github.com/nerc-project/github-runner-bootstrap.git
$ cd github-runner-bootstrap
$ read -s PERSONAL_ACCESS_TOKEN; export PERSONAL_ACCESS_TOKEN
(type your password and press enter)
$ bash bootstrap.sh some-org some-repo "prod somehost linux" 
```
