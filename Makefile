# Terraform and Salt operations Makefile

# Load environment variables from .env
ifneq (,$(wildcard .env))
    include .env
    export $(shell sed 's/=.*//' .env)
endif

# make VERBOSE nonempty to see raw commands (or provide on command line)
ifndef VERBOSE
VERBOSE:=
MAKEFLAGS += --no-print-directory
endif
ifndef LOG
LOG:= error
endif

SHOW:=@echo
# use HIDE to run commands invisibly, unless VERBOSE defined
HIDE:=$(if $(VERBOSE),,@)

# Colors for better visibility
YELLOW := \033[1;33m
GREEN := \033[1;32m
NC := \033[0m # No Color
COLOR := '--force-color'
# Default target
.DEFAULT_GOAL := help

.PHONY: help plan apply destroy test dns upload ssh deploy
help: ## Show this help.
	@echo "$(GREEN)Available commands:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "$(YELLOW)%-20s$(NC) | %s\n", $$1, $$2}'

gentf: ## Generate terraform.tfvars file
	$(HIDE) ./gen_tf.py salt/pillar/senec.sls

plan: ## Run terraform plan
	$(SHOW) "${GREEN}Running terraform plan...${NC}"
	$(HIDE)cd $(TERRAFORM_DIR) && terraform init
	$(HIDE)cd $(TERRAFORM_DIR) && terraform plan

apply: ## Run terraform apply
	$(SHOW) "${GREEN}Running terraform apply...${NC}"
	$(HIDE)cd $(TERRAFORM_DIR) && terraform init
	$(HIDE)cd $(TERRAFORM_DIR) && terraform apply

destroy: ## Destroy Terraform infrastructure  (asks for confirmation)
	$(SHOW) "${YELLOW}WARNING: This will destroy all infrastructure in $(TERRAFORM_DIR)!${NC}"
	@read -p "Are you sure? Type 'yes' to proceed: " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		echo "${GREEN}Destroying Terraform infrastructure...${NC}"; \
		cd $(TERRAFORM_DIR) && terraform destroy; \
	else \
		echo "${YELLOW}Operation canceled.${NC}"; \
	fi

test: ## Run test to see if all servers are available
	$(SHOW) "${GREEN}Running test.ping...${NC}"
	$(HIDE)ssh $(SSH_USER)@$(REMOTE_HOST) "sudo salt '*' test.ping $(COLOR)"

dns: ## Update internal DNS on all servers
	$(SHOW) "${GREEN}Updating internal DNS on $(REMOTE_HOST)...${NC}"
	$(HIDE)ssh $(SSH_USER)@$(REMOTE_HOST) "sudo salt '*' state.sls enable_salt_mine $(COLOR)"
	$(HIDE)ssh $(SSH_USER)@$(REMOTE_HOST) "sudo systemctl restart salt-minion"
	$(HIDE)ssh $(SSH_USER)@$(REMOTE_HOST) "sleep 5; sudo salt '*' state.sls update_hosts $(COLOR)"

upload: ## Upload Salt files to /srv/ on the remote host
	$(SHOW) "${GREEN}Syncing Salt files to $(REMOTE_HOST)...${NC}"
	$(HIDE)rsync -az --info=progress2 $(if $(DRYRUN),--dry-run,) --delete --rsync-path="sudo rsync" salt/ $(SSH_USER)@$(REMOTE_HOST):/srv/

ssh: ## SSH into LB, web1, web2, or web3 via $(REMOTE_HOST) as a jumpbox (usage: make ssh TARGET=web1)
	@if [ -z "$(TARGET)" ]; then \
		echo -e "${YELLOW}Usage: make ssh TARGET=<lb|web1|web2|web3>${NC}"; \
		exit 1; \
	fi
	$(SHOW) "${GREEN}Connecting to $(TARGET) via $(REMOTE_HOST) as jumpbox...${NC}"
	$(HIDE)ssh -J $(SSH_USER)@$(REMOTE_HOST) $(SSH_USER)@$(TARGET)

deploy: ## Deploy everything
	$(SHOW) "${GREEN}Deploying everything... Sit back and relax${NC}"
	$(HIDE)ssh $(SSH_USER)@$(REMOTE_HOST) "sudo salt-run state.orchestrate orch.deploy -l info $(COLOR)"

reboot: ## Reboot LB, web1, web2, or web3 (usage: make reboot TARGET=web1)
	@if [ -z "$(TARGET)" ]; then \
		echo -e "${YELLOW}Usage: make reboot TARGET=<lb|web1|web2|web3>${NC}"; \
		exit 1; \
	fi
	$(SHOW) "${GREEN}Connecting to $(TARGET) via $(REMOTE_HOST) as jumpbox...${NC}"
	$(HIDE)ssh $(SSH_USER)@$(REMOTE_HOST) "sudo salt $(TARGET) system.reboot $(COLOR)"

service: ## Start|Stop|Restart nginx|php8.1-fpm|mariadb on web1|web2|web3 (usage: make service ACTION=stop SERVICE=nginx TARGET=web1)
	@if [ -z "$(TARGET)" ] || [ -z "$(SERVICE)" || [ -z $(ACTION) ]; then \
                echo -e "${YELLOW}Usage: make service SERVICE=|nginx|php8.1-fpm|mariadb TARGET=<|web1|web2|web3>${NC}"; \
                exit 1; \
        fi
	$(SHOW) "${GREEN}Connecting to $(TARGET) via $(REMOTE_HOST) as jumpbox...${NC}"
	$(HIDE)ssh $(SSH_USER)@$(REMOTE_HOST) "sudo salt $(TARGET) service.$(ACTION) $(SERVICE) $(COLOR)"

dbstatus: ## Run queries to check DB cluster status
	$(SHOW) "${GREEN}Running DB cluster status on web1...${NC}"
	$(HIDE)ssh $(SSH_USER)@$(REMOTE_HOST) "sudo salt 'web1' state.sls mariadb.status $(COLOR)"

