# ============================================================================
# POWERLEVEL10K INSTANT PROMPT
# ============================================================================
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ============================================================================
# HELPERS — só adiciona ao PATH/sourceia se o destino existir.
# Mantém o zshrc utilizável mesmo em máquinas onde algumas ferramentas faltam.
# ============================================================================
_path_prepend() { [[ -d $1 ]] && export PATH="$1:$PATH"; }
_path_append()  { [[ -d $1 ]] && export PATH="$PATH:$1"; }
_source_if()    { [[ -r $1 ]] && source "$1"; }
_have()         { command -v "$1" &>/dev/null; }

# ============================================================================
# POWERLEVEL10K THEME
# ============================================================================
_source_if /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
_source_if ~/.p10k.zsh

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
_path_append "$ANDROID_HOME/emulator"
_path_append "$ANDROID_HOME/platform-tools"
_path_append "$ANDROID_HOME/cmdline-tools/latest/bin"

if [[ -d /opt/homebrew/opt/openjdk@17 ]]; then
  export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
  _path_prepend /opt/homebrew/opt/openjdk@17/bin
fi

# ============================================================================
# PYTHON (PYENV) — lazy-init, shims no PATH se existirem
# ============================================================================
if _have pyenv; then
  export PYENV_ROOT="$HOME/.pyenv"
  _path_prepend "$PYENV_ROOT/shims"
  pyenv() { unset -f pyenv; eval "$(command pyenv init -)"; pyenv "$@"; }
fi

# ============================================================================
# RUBY (RBENV) — lazy-init, shims no PATH se existirem
# ============================================================================
if _have rbenv; then
  _path_prepend "$HOME/.rbenv/shims"
  rbenv() { unset -f rbenv; eval "$(command rbenv init - zsh)"; rbenv "$@"; }
fi

# ============================================================================
# NODE.JS (FNM)
# ============================================================================
# FNM (Fast Node Manager) — gerencia versões automaticamente com --use-on-cd.
# nvm foi removido por redundância: fnm cobre o mesmo caso de uso e é instantâneo.
if _have fnm; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

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

# iOS Simulator — boota um device com iOS 18.6 e abre o Simulator.app.
# Uso: simulator                       (default: iPhone 16 Pro)
#      simulator "iPhone 16"           (qualquer nome listado em `xcrun simctl list devices`)
simulator() {
  local device="${1:-iPhone 16 Pro}"
  local runtime="iOS 18.6"

  if ! command -v xcrun &>/dev/null; then
    print -u2 "Xcode não encontrado. Instale pela App Store."
    return 1
  fi

  local udid
  udid=$(xcrun simctl list devices "$runtime" available 2>/dev/null \
    | grep -E "^[[:space:]]+${device} \(" \
    | head -1 \
    | grep -oE '[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}')

  if [[ -z "$udid" ]]; then
    print -u2 "Nenhum '$device' com $runtime disponível."
    print -u2 "Em Xcode > Settings > Platforms, instale o runtime iOS 18.6."
    return 1
  fi

  xcrun simctl boot "$udid" 2>/dev/null
  open -a Simulator
}

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
if _have zoxide; then
  _cached_init zoxide init zsh
fi

# bun completions
_source_if "$HOME/.bun/_bun"

# bun
if [[ -d "$HOME/.bun" ]]; then
  export BUN_INSTALL="$HOME/.bun"
  _path_prepend "$BUN_INSTALL/bin"
fi

if _have go; then
  alias air='$(go env GOPATH)/bin/air'
  _path_append "$(go env GOPATH)/bin"
fi

# Detecção automática de versão Node por diretório:
# delegada ao fnm via `--use-on-cd` (configurado no bloco FNM acima).

_path_prepend "$HOME/.local/bin"
[[ -x /usr/bin/python3 ]] && export CLOUDSDK_PYTHON=/usr/bin/python3
_path_prepend /opt/homebrew/share/google-cloud-sdk/bin

# pnpm
if [[ -d "$HOME/Library/pnpm" ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
  case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
  esac
fi
# pnpm end

# ============================================================================
# HERD-LITE (PHP)
# ============================================================================
if [[ -d "$HOME/.config/herd-lite/bin" ]]; then
  _path_prepend "$HOME/.config/herd-lite/bin"
  export PHP_INI_SCAN_DIR="$HOME/.config/herd-lite/bin:${PHP_INI_SCAN_DIR:-}"
fi

# ============================================================================
# MAESTRO
# ============================================================================
_path_append "$HOME/.maestro/bin"

# ============================================================================
# ZCOMPILE — recompila .zshrc em bytecode quando ele muda
# ============================================================================
if [[ ~/.zshrc -nt ~/.zshrc.zwc || ! -s ~/.zshrc.zwc ]]; then
  zcompile ~/.zshrc 2>/dev/null
fi

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
