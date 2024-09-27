# dotfiles for devpod devcontainer
my devpod dotfile repo

# Requirements
On the local machine 
- [docker](https://www.docker.com/products/docker-desktop/)
- [devpod](https://devpod.sh/)

need to be installed.

Additionally the projects `.devcontainer.json` needs to contain the following part in order to add _nix_ as a feature:
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
