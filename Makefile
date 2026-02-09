.PHONY: help install deploy logs local-clean local-up local-down status

help: ## Show this help
	@echo "Agent Zero Enterprise - Available Commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## Install Railway CLI
	npm install -g @railway/cli
	railway --version

deploy: ## Deploy to Railway
	./scripts/setup.sh

logs: ## View production logs
	railway logs --tail 100

status: ## Check service status
	railway status

domain: ## Show/update domain
	railway domain

local-up: ## Start local development stack
	docker-compose up -d
	@echo "🌐 Web UI: http://localhost:3000"
	@echo "🔌 API: http://localhost:50001"

local-down: ## Stop local stack
	docker-compose down

local-logs: ## View local logs
	docker-compose logs -f

local-clean: ## Clean local data (WARNING: destructive)
	docker-compose down -v
	docker system prune -f

health: ## Check health endpoint
	./scripts/healthcheck.sh http://localhost:80/health

config: ## View Railway configuration
	railway variables
