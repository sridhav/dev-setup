# Day-to-day commands for the dev setup. Run `make` to list them.
# Each target is a thin wrapper around a script in sh/, which also run on their own.
#
# The loop:
#   Mac A:  edit a config (it's symlinked, so just edit it in place) → make push
#   Mac B:  make update

SHELL := /bin/bash
.DEFAULT_GOAL := help

S := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))/sh

.PHONY: help install force-install dry-run backup update plugins upgrade push status brew-diff version history rollback release

help: ## Show this help
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  \033[35m%-14s\033[0m %s\n", $$1, $$2}'

install: ## First-time setup: install everything missing, link configs
	@$(S)/install.sh

force-install: ## Back up all configs, then reinstall oh-my-zsh, plugins and links from scratch
	@$(S)/install.sh --force

dry-run: ## Show what install would do without changing anything
	@$(S)/install.sh --dry-run

backup: ## Copy all configs to ~/.dev-setup-backup/<timestamp>/ without changing anything
	@$(S)/backup.sh

update: ## Move to the latest version and apply it (run this on every Mac)
	@$(S)/update.sh

plugins: ## Sync shell, tmux, and Neovim plugins
	@$(S)/plugins.sh

upgrade: ## Move to newer versions on this Mac, then run `make push` to share them
	@$(S)/upgrade.sh

push: ## Commit and push local changes (optional: msg="...")
	@$(S)/push.sh $(if $(msg),"$(msg)")

status: ## Show uncommitted changes and any configs that aren't linked
	@$(S)/status.sh

brew-diff: ## List Homebrew packages on this Mac that are missing from sh/packages.sh
	@$(S)/brew-diff.sh

version: ## Show which version this Mac is on and whether it's behind
	@$(S)/version.sh

history: ## List recent versions (commits), newest first
	@$(S)/history.sh

rollback: ## Put this Mac back on an earlier version: make rollback to=<commit|tag>
	@$(S)/rollback.sh "$(to)"

release: ## Tag the current version (vYYYY.MM.DD, or name=...) and push the tag
	@$(S)/release.sh $(if $(name),"$(name)")
