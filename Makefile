.PHONY: switch check update mas-update test fmt

# The single darwinConfiguration in flake.nix.
HOST := personal
FLAKE := $(shell pwd)

# Apply the configuration. This is the only command needed day to day.
switch:
	@sudo darwin-rebuild switch --flake "$(FLAKE)#$(HOST)"

# Evaluate and dry-build without touching the system.
check:
	@nix flake check --no-build
	@nix build "$(FLAKE)#darwinConfigurations.$(HOST).system" --dry-run

# Move everything forward. Homebrew upgrades are deliberate rather than part
# of every activation, so they happen here instead of in onActivation.
update:
	@nix flake update
	@$(MAKE) --no-print-directory switch
	@brew upgrade
	@mise upgrade --yes
	@$(MAKE) --no-print-directory mas-update

# homebrew.masApps installs but does not upgrade.
mas-update:
	@mas upgrade


# Stubbed harness for bootstrap.sh; proves control flow, not behaviour.
test:
	@bash tests/bootstrap.sh

# Format the nix files.
fmt:
	@nix fmt
