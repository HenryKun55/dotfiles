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
backup_and_link "$DOTFILES/zsh/.antigenrc"   "$HOME/.antigenrc"
backup_and_link "$DOTFILES/git/.gitconfig"   "$HOME/.gitconfig"

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

# ── Bun ─────────────────────────────────────────────────────────────
if [[ ! -d "$HOME/.bun" ]]; then
  info "Installing Bun..."
  curl -fsSL https://bun.sh/install | bash || warn "Bun install failed."
else
  info "Bun already installed."
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

# ── Done ────────────────────────────────────────────────────────────
echo ""
info "Setup complete!"
echo ""
warn "Recommended:"
echo "  • Run ./doctor.sh to verify everything is in place"
echo "  • Restart your shell (or 'exec zsh') to pick up the new config"
echo ""
