# dotfiles for devpod devcontainer
my devpod dotfile repo

# Requirements
On the local machine _docker_ needs to be installed.

Additionailly in the project in the `.devcontainer.json` the following part has to be included to add _nix_ as a feature:
```json
"features": {
         "ghcr.io/devcontainers/features/nix:1": {}
     },
```

# Usage
Install devpod local machine, `cd` into your project-dir (containing the `.devcontainer`-dir or the `.devcontainer.json`) and run
```bash
devpod up . --provider docker --dotfiles https://github.com/timo-y/dotfiles.git
```
