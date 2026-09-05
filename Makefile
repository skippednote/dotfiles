.PHONY: switch check update mas-update test fmt drift packages packages-lock


# Picked from the machine itself, so `make switch` needs no flag and cannot
# be pointed at the wrong host by accident.
HOST := $(shell scutil --get LocalHostName)
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
#
# There is no global `mise upgrade`: [tools] is empty on both machines, so it
# would be a no-op. Project tools upgrade inside their own directories.
update:
	@nix flake update
	@$(MAKE) --no-print-directory switch
	@brew upgrade
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

# Report where this machine has drifted from the repo.
drift:
	@bash scripts/drift-check.sh

# List the Nix packages actually installed in this machine's user profile.
# Reads the live profile rather than the flake, so it shows what is there
# rather than what should be.
packages:
	@nix-store -q --references /etc/profiles/per-user/$(USER) \
	  | xargs -n1 nix-store -q --references \
	  | sed 's|/nix/store/[a-z0-9]*-||' \
	  | grep -vE -- '-(man|doc|info|dev|debug)$$' \
	  | sort -u

# Regenerate packages.lock. Run this whenever the package set changes, and
# commit the result alongside the change.
packages-lock:
	@bash scripts/packages-lock.sh
