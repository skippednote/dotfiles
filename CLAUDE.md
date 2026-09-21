# dotfiles

- `git add` new files under `home/` before `nix flake check`. Flake eval only
  sees tracked paths; the `link` assert in nix/modules/home.nix reports
  `home/<path> does not exist` for a file that is plainly there.
- Every link is out-of-store: `link` wraps `mkOutOfStoreSymlink`, so edits to
  a tracked file under `home/` are live immediately. A `make switch` is only
  needed to add, remove or repoint a link.
- Apply with `make switch`.
