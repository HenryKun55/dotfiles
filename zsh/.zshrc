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
# PYTHON (PYENV)
# ============================================================================
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# ============================================================================
# RUBY (RBENV)
# ============================================================================
eval "$(rbenv init - zsh)"

# ============================================================================
# NODE.JS (FNM & NVM)
# ============================================================================
# FNM (Fast Node Manager)
export PATH=$PATH:$HOME/.local/share/fnm/node-versions/v14.21.3/installation/bin
eval "$(fnm env --use-on-cd --shell zsh)"

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# ============================================================================
# PUPPETEER
# ============================================================================
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export PUPPETEER_EXECUTABLE_PATH=$(which chromium)

# ============================================================================
# ITERM2 INTEGRATION
# ============================================================================
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

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
# ZOXIDE (carregar por último)
# ============================================================================
eval "$(zoxide init zsh)"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
if command -v go &>/dev/null; then
  alias air='$(go env GOPATH)/bin/air'
  export PATH=$PATH:$(go env GOPATH)/bin/
fi

# Detecta e usa automaticamente a versão do Node especificada no .nvmrc
autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

# Add Visual Studio Code (code)
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

export PATH="$HOME/.local/bin:$PATH"
export CLOUDSDK_PYTHON=$(which python3)
export PATH="/opt/homebrew/share/google-cloud-sdk/bin:$PATH"
export DEVELOPER_DIR=/Library/Developer/CommandLineTools

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
