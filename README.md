# dotfiles 
My dotfile repo.

# Requirements
## Linux
None, just clone the repo and run the setup.sh script. It will first install Nix, then Stow, then the dotfiles and finally the dependencies in the Nix-config.

You can also use the followng command to clone the repo and run the setup.sh script:
WARNING: Don't run commands from the internet without checking the code first!
```bash
curl -sSL https://raw.githubusercontent.com/timo-y/dotfiles/main/setup.sh | bash
```

## Devpod

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

### Usage
In the console `cd` into your project-dir (containing the `.devcontainer`-dir or the `.devcontainer.json`) and run
```bash
devpod up . --provider docker --dotfiles https://github.com/timo-y/dotfiles.git
```
