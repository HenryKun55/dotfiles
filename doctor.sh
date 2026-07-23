#!/usr/bin/env bash
# Diagnostic for the dotfiles: shows what's installed and what's missing.
# Run after install.sh, or whenever you suspect something is off.

set -u

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'

ok()      { printf "  ${GREEN}✓${NC}  %s\n" "$1"; }
miss()    { printf "  ${RED}✗${NC}  %s${YELLOW}%s${NC}\n" "$1" "${2:+  → $2}"; MISSING=$((MISSING+1)); }
skipped() { printf "  ${BLUE}○${NC}  %s ${YELLOW}(optional, not installed)${NC}${BLUE}%s${NC}\n" "$1" "${2:+  → $2}"; }
hdr()     { printf "\n${BLUE}── %s ──${NC}\n" "$1"; }

MISSING=0

check_bin() {
  local name=$1 hint=${2:-}
  if command -v "$name" &>/dev/null; then ok "$name ($(command -v "$name"))"
  else miss "$name" "$hint"; fi
}

check_dir() {
  local path=$1 hint=${2:-}
  if [[ -d "$path" ]]; then ok "$path"
  else miss "$path" "$hint"; fi
}

check_file() {
  local path=$1 hint=${2:-}
  if [[ -e "$path" ]]; then ok "$path"
  else miss "$path" "$hint"; fi
}

check_symlink() {
  local link=$1 target=$2
  if [[ -L "$link" && "$(readlink "$link")" == "$target" ]]; then
    ok "$link → $target"
  elif [[ -e "$link" ]]; then
    miss "$link" "exists but not the symlink we expect (run install.sh)"
  else
    miss "$link" "symlink missing (run install.sh)"
  fi
}

hdr "Homebrew"
check_bin brew "install: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""

hdr "CLI tools (from Brewfile)"
check_bin nvim     "brew install neovim"
check_bin tmux     "brew install tmux"
check_bin rg       "brew install ripgrep"
check_bin lazygit  "brew install lazygit"
check_bin gh       "brew install gh"
check_bin jq       "brew install jq"
check_bin fzf      "brew install fzf"
check_bin zoxide   "brew install zoxide"
check_bin prettierd "brew install prettierd"
check_bin lua-language-server "brew install lua-language-server"
check_bin tree-sitter "brew install tree-sitter-cli"

hdr "Shell extras"
check_file /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme   "brew install powerlevel10k"
check_file /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh "brew install zsh-syntax-highlighting"
check_file /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh         "brew install zsh-autosuggestions"

hdr "Runtimes & version managers"
check_bin fnm    "brew install fnm"
check_bin pyenv  "brew install pyenv"
check_bin rbenv  "brew install rbenv"

# openjdk@17 é opt-in (install.sh pergunta). Ausência aqui é normal.
if [[ -d /opt/homebrew/opt/openjdk@17 ]]; then
  ok "/opt/homebrew/opt/openjdk@17"
else
  skipped "/opt/homebrew/opt/openjdk@17" "brew install openjdk@17 (só pra Android/JVM)"
fi

if command -v fnm &>/dev/null; then
  installed=$(fnm list 2>/dev/null | grep -E 'v[0-9]+' | wc -l | tr -d ' ')
  if [[ "$installed" -gt 0 ]]; then ok "fnm has $installed Node version(s) installed"
  else miss "no Node versions installed via fnm" "fnm install --lts && fnm default lts-latest"; fi
fi

check_dir "$HOME/.bun" "install: curl -fsSL https://bun.sh/install | bash"

hdr "C/C++ toolchain"
# clang/clang++/clangd/make/lldb vêm do Xcode Command Line Tools.
check_bin clang    "xcode-select --install"
check_bin clang++  "xcode-select --install"
check_bin clangd   "xcode-select --install  (LSP de C/C++ no nvim)"
check_bin make     "xcode-select --install"
check_bin lldb     "xcode-select --install  (debugger; gdb não roda em arm64 macOS)"
check_bin cmake    "brew install cmake"
check_bin ninja    "brew install ninja"
# clang-format é opcional (formatação); o Xcode CLT não o inclui.
if command -v clang-format &>/dev/null; then
  ok "clang-format ($(command -v clang-format))"
else
  skipped "clang-format" "brew install clang-format"
fi

hdr "Dotfiles symlinks"
DOTFILES="${DOTFILES:-$HOME/dotfiles}"
check_symlink "$HOME/.config/nvim"      "$DOTFILES/nvim"
check_symlink "$HOME/.config/alacritty" "$DOTFILES/alacritty"
check_symlink "$HOME/.tmux.conf"        "$DOTFILES/tmux/tmux.conf"
check_symlink "$HOME/.zshrc"            "$DOTFILES/zsh/.zshrc"
check_symlink "$HOME/.zshenv"           "$DOTFILES/zsh/.zshenv"
check_symlink "$HOME/.zprofile"         "$DOTFILES/zsh/.zprofile"
check_symlink "$HOME/.p10k.zsh"         "$DOTFILES/zsh/.p10k.zsh"
check_symlink "$HOME/.gitconfig"        "$DOTFILES/git/.gitconfig"

hdr "Editor / plugin managers state"
check_dir "$HOME/.tmux/plugins/tpm"            "git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm"
check_dir "$HOME/.local/share/nvim/lazy"       "open nvim once — lazy.nvim bootstraps automatically"
check_file "$HOME/.tpick/tpick.sh"             "git clone https://github.com/HenryKun55/tpick ~/.tpick"

echo ""
if [[ "$MISSING" -eq 0 ]]; then
  printf "${GREEN}All checks passed.${NC}\n"
  exit 0
else
  printf "${YELLOW}%d item(s) missing.${NC} Run install.sh, then re-run this script.\n" "$MISSING"
  exit 1
fi
