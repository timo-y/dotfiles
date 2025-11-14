# dotfiles 
My dotfile repo.

# Requirements
## Linux
None, just clone the repo into ~ and run the setup.sh script. It will first install Nix, then Stow, then the dotfiles and finally the dependencies in the Nix-config.

## Devpod

On the local machine 
- [docker](https://www.docker.com/products/docker-desktop/)
- [devpod](https://devpod.sh/)

need to be installed.

### Usage
In the console `cd` into your project-dir (containing the `.devcontainer`-dir or the `.devcontainer.json`) and run
```bash
devpod up . --provider docker --dotfiles https://github.com/timo-y/dotfiles.git
```
