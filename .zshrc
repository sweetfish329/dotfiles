# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export SAVEHIST=100000

# Initialize sheldon (zsh-completions needs to be added to fpath before compinit)
eval "$(sheldon --quiet source)"

autoload -Uz compinit
compinit

# fzf setup (must be after compinit and sheldon)
source <(fzf --zsh)

if command -v abbr &> /dev/null; then
  abbr -S -q ei="eza --icons --git"
  abbr -S -q ea="eza -la --icons --git"
  abbr -S -q ee="eza -aahl --icons --git"
  abbr -S -q et="eza -T -L 3 -a -I 'node_modules|.git|.cache' --icons"
  abbr -S -q ls="eza --icons --git"
  abbr -S -q la="eza -la --icons --git"
  abbr -S -q ll="eza -aahl --icons --git"
  abbr -S -q vi="vim"
  abbr -S -q tree="eza -T -L 3 -a -I 'node_modules|.git|.cache' --icons"

  abbr -S -q cat="cat -n"
fi