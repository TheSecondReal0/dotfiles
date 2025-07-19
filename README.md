# Setup
Clone into `~/dotfiles`

## Zsh
### Oh-my-zsh
1. Install [oh-my-zsh](https://ohmyz.sh)
2. Replace `~/.zshrc` contents with:
```
source ~/dotfiles/zsh/.zshrc
```
### Syntax highlighting
1. Install [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
2. I source zsh-syntax-highlighting at the end of `~/.zshrc` to make sure it happens last

### Summary
* Better tab-completion
* Powerline prompt
* Working directory truncating (e.g. `~/dev/game/cool/strategy` -> `~/d/g/c/strategy`)
* Prompt changes to be more minimal after entering command, avoids old powerline prompts uglifying scrollback buffer

## Tmux
### Setup
1. Install [tpm](https://github.com/tmux-plugins/tpm)
2. Add this to `~/.tmux.conf`:
```
source ~/dotfiles/tmux/.tmux.conf

# optional
set -g default-shell /bin/zsh
```
3. Launch tmux and do Prefix+I to install plugins

### Summary
* Sets prefix to Ctrl + Space
* Tokyo night theme
* Enable mouse usage
* Install (tmux-sensible)[https://github.com/tmux-plugins/tmux-sensible]
* Session saving and restoring across reboots with [tmux-ressurect](https://github.com/tmux-plugins/tmux-resurrect), autosave with [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum)
  a. Save session with Prefix + s, reload with Prefix + r

## Kitty
1. Install [kitty](https://sw.kovidgoyal.net/kitty/)
2. Add this to `~/.config/kitty/kitty.conf`:
```
include ~/dotfiles/kitty/kitty.conf
```

### Summary
* Tokyo night theme
* Reasonable clipboard behavior (default is append to clipboard not overwrite???)

## Neovim
Find neovim config/setup [here](https://github.com/TheSecondReal0/nvim)

