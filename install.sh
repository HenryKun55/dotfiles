#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d%H%M%S)"

# ── Colors ──────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[dotfiles]${NC} $1"; }
warn()  { echo -e "${YELLOW}[dotfiles]${NC} $1"; }
error() { echo -e "${RED}[dotfiles]${NC} $1"; }

# y/N prompt — default no, auto-no se rodar sem TTY (CI, pipe, etc).
ask_yn() {
  local question=$1
  if [[ ! -t 0 ]]; then
    info "Non-interactive: skipping '$question'"
    return 1
  fi
  read -r -p "$(echo -e "${YELLOW}[?]${NC} $question [y/N] ")" response
  [[ "$response" =~ ^[Yy]$ ]]
}

# ── macOS check ─────────────────────────────────────────────────────
if [[ "$(uname)" != "Darwin" ]]; then
  error "This script only supports macOS."
  exit 1
fi

# ── Xcode Command Line Tools (git, clang, make) ────────────────────
if ! xcode-select -p &>/dev/null; then
  info "Installing Xcode Command Line Tools (a window will open; run this script again when it finishes)..."
  xcode-select --install || true
  exit 0
fi

# ── Homebrew ────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  info "Homebrew already installed."
fi

# ── Brew bundle ─────────────────────────────────────────────────────
if [[ -f "$DOTFILES/Brewfile" ]]; then
  info "Running brew bundle..."
  brew bundle --file="$DOTFILES/Brewfile" || warn "Some brew packages failed to install. Check output above."
else
  warn "Brewfile not found, skipping."
fi

# ── Optional: Java (openjdk@17) ────────────────────────────────────
# Pesado (~500MB) e só usado pra Android/JVM. Pergunta antes de instalar.
if [[ -d /opt/homebrew/opt/openjdk@17 ]]; then
  info "openjdk@17 already installed."
elif ask_yn "Set up Java (openjdk@17) for Android/JVM dev?"; then
  info "Installing openjdk@17..."
  brew install openjdk@17 || warn "openjdk@17 install failed."
fi

# ── Helper: backup and symlink ──────────────────────────────────────
backup_and_link() {
  local src="$1"
  local dest="$2"

  # If dest is already the correct symlink, skip
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    info "Already linked: $dest → $src"
    return
  fi

  # Backup existing file/dir (not symlinks pointing elsewhere)
  if [[ -e "$dest" || -L "$dest" ]]; then
    mkdir -p "$BACKUP_DIR"
    warn "Backing up $dest → $BACKUP_DIR/"
    mv "$dest" "$BACKUP_DIR/"
  fi

  # Create parent directory if needed
  mkdir -p "$(dirname "$dest")"

  ln -s "$src" "$dest"
  info "Linked: $dest → $src"
}

# ── Symlinks ────────────────────────────────────────────────────────
info "Creating symlinks..."

# Directories
backup_and_link "$DOTFILES/nvim"      "$HOME/.config/nvim"
backup_and_link "$DOTFILES/alacritty" "$HOME/.config/alacritty"

# Individual files
backup_and_link "$DOTFILES/tmux/tmux.conf"   "$HOME/.tmux.conf"
backup_and_link "$DOTFILES/zsh/.zshrc"       "$HOME/.zshrc"
backup_and_link "$DOTFILES/zsh/.zshenv"      "$HOME/.zshenv"
backup_and_link "$DOTFILES/zsh/.zprofile"    "$HOME/.zprofile"
backup_and_link "$DOTFILES/zsh/.p10k.zsh"    "$HOME/.p10k.zsh"
backup_and_link "$DOTFILES/git/.gitconfig"   "$HOME/.gitconfig"

# ── Proteção contra chave no git (o repositório é público) ─────────
chmod +x "$DOTFILES/git/hooks/pre-commit"
git -C "$DOTFILES" config core.hooksPath git/hooks
info "pre-commit hook active (blocks commits that look like keys)."

# ── TPM (Tmux Plugin Manager) ──────────────────────────────────────
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR" ]]; then
  info "Cloning TPM (Tmux Plugin Manager)..."
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
  info "TPM already installed."
fi

# ── Node.js (fnm) ─────────────────────────────────────────────────
if command -v fnm &>/dev/null; then
  eval "$(fnm env --shell bash)"
  if fnm current &>/dev/null && [[ "$(fnm current)" != "none" ]]; then
    info "fnm default already set: $(fnm current)"
  else
    info "Installing Node.js LTS via fnm..."
    fnm install --lts
    fnm default lts-latest
    info "Node $(fnm current) set as default."
  fi
else
  warn "fnm not found, skipping Node.js install."
fi

# ── Claude Code ─────────────────────────────────────────────────────
# Fica no node do fnm (npm global). O rtk, que o hook dele chama, vem do Brewfile.
if command -v claude &>/dev/null; then
  info "Claude Code already installed: $(claude --version 2>/dev/null | head -1)"
elif command -v npm &>/dev/null; then
  info "Installing Claude Code..."
  npm install -g @anthropic-ai/claude-code || warn "Claude Code install failed."
else
  warn "npm not found, skipping Claude Code install."
fi

# ── Bun ─────────────────────────────────────────────────────────────
if [[ ! -d "$HOME/.bun" ]]; then
  info "Installing Bun..."
  curl -fsSL https://bun.sh/install | bash || warn "Bun install failed."
else
  info "Bun already installed."
fi

# ── tpick (terminal theme picker) ──────────────────────────────────
# Clona direto (sem rodar tpick/install.sh) pra não duplicar a integração
# de shell — o .zshrc dos dotfiles já faz o source com guard.
TPICK_DIR="$HOME/.tpick"
if [[ ! -d "$TPICK_DIR/.git" ]]; then
  info "Cloning tpick to $TPICK_DIR..."
  git clone --quiet https://github.com/HenryKun55/tpick "$TPICK_DIR" \
    || warn "tpick clone failed."
else
  info "tpick already cloned at $TPICK_DIR."
fi

# Baixa os temas pro alacritty se ainda não tiver
THEMES_DIR="$HOME/.config/alacritty/themes"
if [[ -d "$TPICK_DIR" && ( ! -d "$THEMES_DIR" || -z "$(ls -A "$THEMES_DIR" 2>/dev/null)" ) ]]; then
  if command -v python3 &>/dev/null; then
    info "Fetching alacritty themes via tpick..."
    python3 "$TPICK_DIR/fetch_themes.py" || warn "tpick theme fetch failed."
  else
    warn "python3 not found, skipping tpick theme fetch."
  fi
fi

# ── Tmux plugins (via TPM, headless) ───────────────────────────────
if [[ -x "$TPM_DIR/bin/install_plugins" ]]; then
  info "Installing tmux plugins via TPM..."
  "$TPM_DIR/bin/install_plugins" || warn "TPM install_plugins reported a problem."
else
  warn "TPM not executable, skipping tmux plugin install."
fi

# ── Neovim plugins (lazy.nvim bootstrap + sync, headless) ──────────
if command -v nvim &>/dev/null; then
  info "Bootstrapping nvim plugins via lazy.nvim (headless, may take 1-2 min)..."
  nvim --headless "+Lazy! sync" +qa 2>&1 | tail -3 || warn "nvim plugin sync reported a problem."
else
  warn "nvim not found, skipping plugin sync."
fi

# ── Segredos: só pastas e permissões, nunca conteúdo ───────────────
# As chaves não vivem neste repositório. O script cria o lugar delas com a
# permissão certa e lista o que falta copiar à mão da máquina antiga.
mkdir -p "$HOME/.config/egoeimi" "$HOME/.ssh"
chmod 700 "$HOME/.config/egoeimi" "$HOME/.ssh"
SECRETS=(
  "$HOME/.config/secrets.env"
  "$HOME/.config/egoeimi/nabati.env"
  "$HOME/.netrc"
  "$HOME/.ssh/config"
  "$HOME/.ssh/id_ed25519_nabati"
  "$HOME/.ssh/id_ed25519_bs4bet"
  "$HOME/.nabati-chat/token.json"
  "$HOME/.nabati-docs"
  "$HOME/Documents/workspace/egoeimi/.gitconfig"
  "$HOME/Documents/workspace/egoeimi/nabati/.gitconfig"
  "$HOME/Documents/workspace/egoeimi/nabati/.env"
)
missing=()
for s in "${SECRETS[@]}"; do
  if [[ -e "$s" ]]; then
    [[ -f "$s" ]] && chmod 600 "$s"
  else
    missing+=("$s")
  fi
done

# ── Done ────────────────────────────────────────────────────────────
echo ""
info "Setup complete!"
if (( ${#missing[@]} )); then
  echo ""
  warn "Copie à mão da máquina antiga (não ficam no git):"
  for s in "${missing[@]}"; do echo "  • $s"; done
fi
echo ""
warn "Recommended:"
echo "  • Run ./doctor.sh to verify everything is in place"
echo "  • Restart your shell (or 'exec zsh') to pick up the new config"
echo ""
