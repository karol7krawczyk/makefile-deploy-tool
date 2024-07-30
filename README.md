# Deployment Makefile Tool

![License](https://img.shields.io/badge/license-MIT-blue.svg)


This repository contains a `Makefile` that simplifies deployment tasks for the application. The Makefile provides commands for deploying the application, creating and restoring backups, managing SSH keys, and more. Uses rsync to deploy the application files to the remote server, excluding specified files and directories.

## Prerequisites

- Ensure you have `ssh` and `rsync` installed on your local machine.
- Make sure you have the necessary SSH access to the remote server.

## Configuration

The Makefile uses the following configuration variables, which you can adjust according to your needs:

```makefile
URL := https://example-domain.com
SSH_USER := user
SSH_HOST := example-domain.com
SSH_PORT := 22
REMOTE_DIR := /srv/example-domain.com/public
BACKUP_DIR := /srv/example-domain.com/backup
PRE_DEPLOY_SCRIPT := pre_deploy.sh
POST_DEPLOY_SCRIPT := post_deploy.sh
EXCLUDES := --exclude '.git' --exclude 'vendor' --exclude '.gitignore' --exclude 'Makefile'
```

## Features
- Deploys the application to the remote server, including pre-deploy and post-deploy script execution and a backup:
- Creates a backup of the current application state on the remote server:
- Tests the HTTP status of the specified URL on the remote server:
- Adds an SSH key to the remote server for secure access:
- Lists all available backup files on the remote server:
- Restores the application state from a specified backup file on the remote server:
- Pre-deploy Script: Transfers and executes the pre_deploy.sh script on the remote server, if it exists.
- Post-deploy Script: Transfers and executes the post_deploy.sh script on the remote server, if it exists.


## Commands
Commands for the deploy group:
-  make deploy         - Deploy the application to the remote server, with pre-deploy and post-deploy script execution and a backup
-  make backup         - Create a backup of the current application state on the remote server
-  make test-url       - Test the HTTP status of a specified URL on the remote server
-  make add-ssh-key    - Add an SSH key to the remote server for secure access
-  make list-backups   - List all available backup files on the remote server
-  make restore-backup - Restore the application state from a specified backup file on the remote server


## Notes
- Ensure the pre_deploy.sh and post_deploy.sh scripts are executable and correctly configured for your deployment needs.
- Adjust the EXCLUDES variable to exclude any additional files or directories as necessary.

## License
This project is licensed under the MIT License - see the LICENSE file for details.
