.PHONY: help backup deploy add-ssh-key list-backups restore-backup test-url help pre-deploy-script post-deploy-script

# Configuration variables
URL := https://example-domain.com
SSH_USER := user
SSH_HOST := example-domain.com
SSH_PORT := 22
REMOTE_DIR := /srv/example-domain.com/public
BACKUP_DIR := /srv/example-domain.com/backup
PRE_DEPLOY_SCRIPT := pre_deploy.sh
POST_DEPLOY_SCRIPT := post_deploy.sh
EXCLUDES := --exclude '.git' --exclude 'vendor' --exclude '.gitignore' --exclude 'Makefile'

# Default target
help:
	@echo "Commands for the deploy group:"
	@echo "  make deploy         - Deploy the application to the remote server, with pre-deploy and post-deploy script execution and a backup"
	@echo "  make backup         - Create a backup of the current application state on the remote server"
	@echo "  make test-url       - Test the HTTP status of a specified URL on the remote server"
	@echo "  make add-ssh-key    - Add an SSH key to the remote server for secure access"
	@echo "  make list-backups   - List all available backup files on the remote server"
	@echo "  make restore-backup - Restore the application state from a specified backup file on the remote server"

# Create a backup of the current application state on the remote server
backup:
	@echo "Creating a backup of the remote directory..."
	@ssh -p $(SSH_PORT) $(SSH_USER)@$(SSH_HOST) "\
		mkdir -p $(BACKUP_DIR) && \
		tar -czf $(BACKUP_DIR)/backup_$$(date +'%Y%m%d_%H%M%S').tar.gz -C $(REMOTE_DIR) ."

# Deploy the application to the remote server
deploy: backup pre-deploy-script
	@echo "Deploying new files to the remote server..."
	rsync -avz $(EXCLUDES) -e "ssh -p $(SSH_PORT)" . $(SSH_USER)@$(SSH_HOST):$(REMOTE_DIR)
	@make post-deploy-script
	@make test-url

# Run pre-deploy script on the remote server
pre-deploy-script:
	@if [ -f $(PRE_DEPLOY_SCRIPT) ]; then \
		echo "Transferring and running pre-deploy script on remote server..."; \
		scp -P $(SSH_PORT) $(PRE_DEPLOY_SCRIPT) $(SSH_USER)@$(SSH_HOST):$(REMOTE_DIR); \
		ssh -p $(SSH_PORT) $(SSH_USER)@$(SSH_HOST) "cd $(REMOTE_DIR) && chmod +x $(PRE_DEPLOY_SCRIPT) && ./$(PRE_DEPLOY_SCRIPT)"; \
	fi

# Run post-deploy script on the remote server
post-deploy-script:
	@if [ -f $(POST_DEPLOY_SCRIPT) ]; then \
		echo "Transferring and running post-deploy script on remote server..."; \
		scp -P $(SSH_PORT) $(POST_DEPLOY_SCRIPT) $(SSH_USER)@$(SSH_HOST):$(REMOTE_DIR); \
		ssh -p $(SSH_PORT) $(SSH_USER)@$(SSH_HOST) "cd $(REMOTE_DIR) && chmod +x $(POST_DEPLOY_SCRIPT) && ./$(POST_DEPLOY_SCRIPT)"; \
	fi

# Add SSH key to the remote server for secure access
add-ssh-key:
	@echo "Adding SSH key to the remote server..."
	@ssh-copy-id -i ~/.ssh/id_rsa.pub -p $(SSH_PORT) $(SSH_USER)@$(SSH_HOST) || \
	echo "Failed to copy SSH key. Ensure the remote server is accessible."

# List all available backup files on the remote server
list-backups:
	@echo "Listing backup files on the remote server..."
	@ssh -p $(SSH_PORT) $(SSH_USER)@$(SSH_HOST) "ls -lh $(BACKUP_DIR)"

# Restore the application state from a specified backup file on the remote server
restore-backup: list-backups
	@read -p "Enter the backup filename to restore (in $(BACKUP_DIR)): " backup_file; \
	ssh -p $(SSH_PORT) $(SSH_USER)@$(SSH_HOST) "tar -xzf $(BACKUP_DIR)/$$backup_file -C $(REMOTE_DIR) && echo 'Backup $$backup_file restored to $(REMOTE_DIR).'"
	@make test-url

# Test the HTTP status of a specified URL on the remote server
test-url:
	@echo "Testing the status of a remote URL..."
	HTTP_STATUS=$$(curl -o /dev/null -s -w "%{http_code}" "$(URL)"); \
	if [ "$$HTTP_STATUS" -eq 200 ]; then \
		echo "Success: The URL is accessible (HTTP Status: $$HTTP_STATUS)"; \
	else \
		echo "Error: The URL returned status $$HTTP_STATUS"; \
	fi
