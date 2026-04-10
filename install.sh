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

# ── Node.js (NVM) ─────────────────────────────────────────────────
if [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]]; then
  source "/opt/homebrew/opt/nvm/nvm.sh"
  if nvm version default &>/dev/null && [[ "$(nvm version default)" != "N/A" ]]; then
    info "NVM default already set: $(nvm version default)"
  else
    info "Installing Node.js LTS via NVM..."
    nvm install --lts
    info "Node $(nvm version) set as default."
  fi
else
  warn "NVM not found, skipping Node.js install."
fi

# ── Done ────────────────────────────────────────────────────────────
echo ""
info "Setup complete!"
echo ""
warn "Next steps:"
echo "  1. Open tmux and press prefix + I to install tmux plugins"
echo "  2. Open nvim and run :PackerSync to install neovim plugins"
echo ""
