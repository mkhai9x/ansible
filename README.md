This repo is heavily influenced by [ALT-F4-LLC](https://github.com/ALT-F4-LLC/dotfiles)'s repo. Go check it out!

## Goals

Provide fully automated `Ubuntu|Arch` development environment that is easy to set up and maintain.

### Why Ansible?

Ansible replicates what we would do to set up a development environment pretty well. There are many automation solutions out there - I happen to enjoy using Ansible.

## Requirements

### Operating System

This Ansible playbook only supports `Ubuntu|Arch` distribution. This is by design to provide a consistent development experience across hosts.

### System Upgrade

Verify your `Ubuntu|Arch` installation has all latest packages installed before running the playbook.

```
# Ubuntu
sudo apt-get update && sudo apt-get upgrade -y
# Arch
sudo pacman -Syu
```

> NOTE: This will take some time.

Install some core packages i.e `curl`, `sudo`

```
# Ubuntu
sudo apt install -y curl sudo
# Arch
sudo pacman -S curl sudo
```

## Setup

### all.yaml values file

The `all.yaml` file allows you to personalize your setup to your needs. This file will be created in the file located at `~/.dotfiles/group_vars/all.yaml` after you [Install this dotfiles](#install) and include your desired settings.

Below is a list of all available values. Not all are required but incorrect values will break the playbook if not properly set.

| Name           | Type                            | Required |
| -------------- | ------------------------------- | -------- |
| git_user_email | string                          | yes      |
| git_user_name  | string                          | yes      |
| exclude_roles  | array `(see group_vars/all)`    | no       |
| ssh_key        | dict `(see SSH Keys below)`     | no       |
| system_host    | dict `(see System Hosts below)` | no       |
| zsh_public     | dict `(see Environment below)`  | no       |
| zsh_private    | dict `(see Environment below)`  | no       |

#### Environment

Manage environment variables by configuring the `zsh_public` and `zsh_private` values in `all.yml`. See both values usecase below.

#### `zsh_public`

The `zsh_public` value allows you to include a dictionary of generic and unsecure key-value pairs that will be stored in a `~/.config/zsh/.zsh_public`.

```yaml
---
zsh_public:
  MY_ENV_VAR: something
```

#### `zsh_private`

The `zsh_private` value allows you to include a dictionary of secure key-value pairs that will be stored in a `~/.config/zsh/.zsh_private`.

```yaml
---
zsh_private:
  MY_ENV_VAR_SECRET: !vault |
    $ANSIBLE_VAULT;1.1;AES256
    62333533626436313366316235626561626635396233303730343332666466393561346462303163
    3666636638613437353663356563656537323136646137630a336332303030323031376164316562
    65333963633339323382938472963766303966643035303234376163616239663539366564396166
    3830376265316231630a623834333061393138306331653164626437623337366165636163306237
    3437
```

### SSH Keys

Manage SSH keys by setting the `ssh_key` value in `all.yml` shown as example below:

```yaml
---
ssh_key:
  <filename>: !vault |
    $ANSIBLE_VAULT;1.1;AES256
    62333533626436313366316235626561626635396233303730343332666466393561346462303163
    3666636638613437483928376563656537323136646137630a336332303030323031376164316562
    65333963633339323762663865363766303966643035303234376163616239663539366564396166
    3830376265316231630a623834333061393138306331653164626437623337366165636163306237
    3437
```

> NOTE: All ssh keys will be stored at `$HOME/.ssh/<filename>`.

### System Hosts

`TODO` : NEED TO SETUP TEST THE /etc/hosts task in the `system` role

Manage `/etc/hosts` by setting the `system_host` value in `.yaml`.

```yaml
---
system_host:
  127.0.0.1: foobar.localhost
```

### Example of `all.yml` file

#### Minimal

Below is a minimal example of `all.yml` file:

```yaml
---
git_user_email: foo@bar.com
git_user_name: Foo Bar
```

#### Advanced

Below is a more advanced example of `all.yml` file:

```yaml
---
git_user_email: foo@bar.com
git_user_name: Foo Bar
exclude_roles:
  - slack
ssh_key: !vault |
  $ANSIBLE_VAULT;1.1;AES256
  62333533626436313366316235626561626635396233303730343332666466393561346462303163
  3666636638613437353663356563656537323136646137630a336332303030323031376164316562
  65333963633339323762663865363766303966643035303234376163616239663539366564396166
  3830376265316231630a623834333061393138306331653164626437623337366165636163306237
  3437
system_host:
  127.0.0.1: foobar.localhost
zsh_public:
  MY_PUBLIC_VAR: foobar
zsh_private:
  MY_SECRET_VAR: !vault |
    $ANSIBLE_VAULT;1.1;AES256
    62333533626436313366316235626561626635396233303730343332666466393561346462303163
    3666636638613437353663356563656537323136646137630a336332303030323031376164316562
    65333963633339323762663865363766303966643035303234376163616239663539366564396166
    3830376265316231630a623834333061393138306331653164626437623337366165636163306237
    3437
```

### vault.secret

The `vault.secret` file allows you to encrypt values with `Ansible vault` and store them securely in source control. Create a file located at `~/.ansible-vault/vault.secret` with a secure password in it.

```bash
vim ~/.ansible-vault/vault.secret
```

To then encrypt values with your vault password use the following:

```bash
$ ansible-vault encrypt_string --vault-password-file $HOME/.ansible-vault/vault.secret "mynewsecret" --name "MY_SECRET_VAR"
$ cat myfile.conf | ansible-vault encrypt_string --vault-password-file $HOME/.ansible-vault/vault.secret --stdin-name "myfile"
```

> NOTE: This file will automatically be detected by the playbook when running `dotfiles` command to decrypt values. Read more on Ansible Vault [here](https://docs.ansible.com/ansible/latest/user_guide/vault.html).

## Usage

### Install

This playbook includes a custom shell script located at `install`. This script is added to your $PATH after installation and can be run multiple times while making sure any Ansible dependencies are installed and updated.
TODO: Need to figure it out how to add install script to `PATH` and then we can run it with ease

This shell script is also used to initialize your environment after installing `Ubuntu|Arch` and performing a full system upgrade as mentioned above.

> NOTE: You must follow required steps before running this command or things may become unusable until fixed.

```bash

# If you have any passwords in the all.yml file, You need to setup ~/.ansible-vault/vault.secret file with containing your ansible password (decrypted version)
# So that when ansible-playboook run, it is able to decrypt those passwords in the all.yml
# And then run the below command for the setup
bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkhai9x/ansible/main/install)"
```

If you want to run only a specific role, you can specify the following bash command:

```bash
curl -fsSL https://raw.githubusercontent.com/mkhai9x/ansible/main/install | bash -s -- --tags comma,seperated,tags
```

### Update

This repository is continuously updated with new features and settings which become available to you when updating.

To update your environment run the `install` command in your shell:

```bash
install
```

This will handle the following tasks:

- Verify Ansible is up-to-date
- Generate SSH keys and add to `~/.ssh/authorized_keys`
- Clone this repository locally to `~/ansible`
- Verify any `ansible-galaxy` plugins are updated
- Run this playbook with the values in `~/ansible/group_vars/all.yaml`

This `install` command is available to you after the first use of this repo, as it adds this repo's `bin` directory to your path, allowing you to call `install` from anywhere.

Any flags or arguments you pass to the `install` command are passed as-is to the `ansible-playbook` command.

For Example: Running the tmux tag with verbosity

```bash
install -t tmux -vvv
```

## TEST

After you make any change base on your own configuration i.e change your passwords in the `all.yml`

You should create your own github repo for the ansible project

Then You can use `Dockerfile` and test your ansible-playbook

```
# Build your docker
docker build -t ansible .

# Run the docker image
docker run -it --rm ansible /bin/bash

# Set up ~/.ansible-vault/vault.secret file

# Run the install script
bash -c "$(curl -fsSL https://raw.githubusercontent.com/<your github>/ansible/main/install)"
```

## TODO

- Change the name of the script from `install` to `dotfiles`?
