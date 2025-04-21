# # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# Quiet the instant prompt warning
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

# Path to your Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(git)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Load Powerlevel10k config if exists
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# # --- ✨ After everything is loaded ---
# if [[ $- == *i* ]] && command -v tmux >/dev/null 2>&1 && [ -z "$TMUX" ] && [ -n "$TERM" ] && [ -t 0 ]; then
#   # Only if tmux can run without error
#   if tmux info &>/dev/null; then
#     (tmux has-session -t dev 2>/dev/null && tmux attach-session -t dev) || tmux new-session -s dev
#   fi
# fi