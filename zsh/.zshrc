# ============================================================================
# POWERLEVEL10K INSTANT PROMPT
# ============================================================================
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ============================================================================
# POWERLEVEL10K THEME
# ============================================================================
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# Configura Powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ============================================================================
# HISTORY CONFIGURATION
# ============================================================================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY           # Adiciona ao histórico ao invés de sobrescrever
setopt SHARE_HISTORY            # Compartilha histórico entre sessões
setopt HIST_IGNORE_DUPS         # Ignora comandos duplicados consecutivos
setopt HIST_IGNORE_ALL_DUPS     # Remove duplicatas antigas
setopt HIST_FIND_NO_DUPS        # Não mostra duplicatas na busca
setopt HIST_IGNORE_SPACE        # Ignora comandos que começam com espaço
setopt HIST_REDUCE_BLANKS       # Remove espaços em branco desnecessários
setopt HIST_VERIFY              # Mostra comando antes de executar do histórico
setopt INC_APPEND_HISTORY       # Adiciona comandos ao histórico imediatamente

# ============================================================================
# LOCALE & LANGUAGE
# ============================================================================
export LANG="en_US.UTF-8"

# ============================================================================
# ANDROID DEVELOPMENT
# ============================================================================
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"

# ============================================================================
# PYTHON (PYENV) — lazy-init, shims sempre no PATH
# ============================================================================
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"
pyenv() { unset -f pyenv; eval "$(command pyenv init -)"; pyenv "$@"; }

# ============================================================================
# RUBY (RBENV) — lazy-init, shims sempre no PATH
# ============================================================================
export PATH="$HOME/.rbenv/shims:$PATH"
rbenv() { unset -f rbenv; eval "$(command rbenv init - zsh)"; rbenv "$@"; }

# ============================================================================
# NODE.JS (FNM)
# ============================================================================
# FNM (Fast Node Manager) — gerencia versões automaticamente com --use-on-cd.
# nvm foi removido por redundância: fnm cobre o mesmo caso de uso e é instantâneo.
export PATH=$PATH:$HOME/.local/share/fnm/node-versions/v14.21.3/installation/bin
eval "$(fnm env --use-on-cd --shell zsh)"

# ============================================================================
# PUPPETEER
# ============================================================================
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# ============================================================================
# ITERM2 INTEGRATION (só carrega quando estiver no iTerm2)
# ============================================================================
if [[ "$LC_TERMINAL" == "iTerm2" ]]; then
  test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
fi

# ============================================================================
# ALIASES
# ============================================================================
alias python="python3"
alias pip="pip3"
alias cls='clear'
alias history='history 1'
alias kodiak-launcher=~/.local/bin/kodiak-launcher

# ============================================================================
# ZSH PLUGINS (carregar antes dos key bindings)
# ============================================================================

# Syntax Highlighting (colorir comandos válidos/inválidos)
if [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Autosuggestions (sugestões baseadas no histórico)
if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  
  # Configuração do autosuggestions
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'  # Cor da sugestão (cinza escuro)
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)  # Usa histórico e completion
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20  # Tamanho máximo do buffer
fi

# ============================================================================
# KEY BINDINGS (HISTORY SEARCH & AUTOSUGGESTIONS)
# ============================================================================

# Carrega as funções de busca no histórico
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Setas para buscar no histórico (filtra pelo que você digitou)
bindkey '^[[A' up-line-or-beginning-search      # Seta para cima
bindkey '^[[B' down-line-or-beginning-search    # Seta para baixo
bindkey '^[OA' up-line-or-beginning-search      # Seta para cima (alternativo)
bindkey '^[OB' down-line-or-beginning-search    # Seta para baixo (alternativo)

# Usando terminfo (mais confiável)
[[ -n "${terminfo[kcuu1]}" ]] && bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
[[ -n "${terminfo[kcud1]}" ]] && bindkey "${terminfo[kcud1]}" down-line-or-beginning-search

# Autosuggestions - aceitar sugestão
bindkey '^ ' autosuggest-accept           # Ctrl+Space aceita a sugestão
bindkey '^[[F' autosuggest-accept         # End aceita a sugestão
bindkey '^[f' forward-word                # Alt+F vai para próxima palavra

# ============================================================================
# ZOXIDE (carregar por último) — saída cacheada em $XDG_CACHE_HOME/zsh/
# ============================================================================
_cached_init() {
  local cmd_name=$1; shift
  local cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/${cmd_name}.zsh"
  [[ -d "${cache:h}" ]] || mkdir -p "${cache:h}"
  if [[ ! -s $cache || $(command -v $cmd_name) -nt $cache ]]; then
    "$cmd_name" "$@" > $cache
  fi
  source $cache
}
_cached_init zoxide init zsh

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
if command -v go &>/dev/null; then
  alias air='$(go env GOPATH)/bin/air'
  export PATH=$PATH:$(go env GOPATH)/bin/
fi

# Detecção automática de versão Node por diretório:
# delegada ao fnm via `--use-on-cd` (configurado no bloco FNM acima).

# Add Visual Studio Code (code)
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

export PATH="$HOME/.local/bin:$PATH"
export CLOUDSDK_PYTHON=/usr/bin/python3
export PATH="/opt/homebrew/share/google-cloud-sdk/bin:$PATH"
export DEVELOPER_DIR=/Library/Developer/CommandLineTools

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
unset DEVELOPER_DIR

# ============================================================================
# ZCOMPILE — recompila .zshrc em bytecode quando ele muda
# ============================================================================
if [[ ~/.zshrc -nt ~/.zshrc.zwc || ! -s ~/.zshrc.zwc ]]; then
  zcompile ~/.zshrc 2>/dev/null
fi
