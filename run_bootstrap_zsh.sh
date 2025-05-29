#!/bin/bash
set -euo pipefail

# --- Logging helpers ---
log() { echo -e "\033[1;32m[$(date +'%H:%M:%S')]\033[0m $*"; }
warn() { echo -e "\033[1;33m⚠️  $*\033[0m"; }
err() { echo -e "\033[1;31m❌ Error: $*\033[0m" >&2; exit 1; }

log "🚀 Starting bootstrap script..."

# --- Command existence check ---
command_exists() { command -v "$1" >/dev/null 2>&1; }

# --- Homebrew auto-install on macOS ---
if [[ "$(uname)" == "Darwin" ]] && ! command_exists brew; then
  log "🔧 Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# --- Install Zsh if missing ---
if ! command_exists zsh; then
  log "🔧 Installing zsh..."
  if command_exists apt; then
    sudo apt update && sudo apt install -y zsh
  elif command_exists brew; then
    brew install zsh
  else
    err "No known package manager to install zsh"
  fi
else
  log "✅ zsh already installed"
fi

# --- Install Git if missing ---
if ! command_exists git; then
  log "🔧 Installing git..."
  if command_exists apt; then
    sudo apt update && sudo apt install -y git
  elif command_exists brew; then
    brew install git
  else
    err "No known package manager to install git"
  fi
else
  log "✅ git already installed"
fi

# --- Install curl if missing ---
if ! command_exists curl; then
  log "🔧 Installing curl..."
  if command_exists apt; then
    sudo apt update && sudo apt install -y curl
  elif command_exists brew; then
    brew install curl
  else
    err "No known package manager to install curl"
  fi
else
  log "✅ curl already installed"
fi

# --- OS check ---
if [[ "$(uname)" != "Darwin" && "$(uname)" != "Linux" ]]; then
  err "Unsupported OS: $(uname)"
fi

ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"

# --- Backup .zshrc if Oh My Zsh is being installed ---
if [ ! -s "$ZSH_DIR/oh-my-zsh.sh" ] && [ -f "$HOME/.zshrc" ]; then
  warn "Backing up existing .zshrc to .zshrc.pre-oh-my-zsh"
  cp "$HOME/.zshrc" "$HOME/.zshrc.pre-oh-my-zsh"
fi

# --- Install Oh My Zsh if missing ---
if [ ! -s "$ZSH_DIR/oh-my-zsh.sh" ]; then
  log "📦 Installing Oh My Zsh..."
  export RUNZSH=no
  export CHSH=no
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  log "✅ Oh My Zsh already installed"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH_DIR/custom}"

# --- Plugin update-or-clone helper ---
update_or_clone() {
  local repo="$1"
  local dest="$2"
  if [ -d "$dest/.git" ]; then
    log "🔄 Updating $(basename "$dest")..."
    git -C "$dest" pull --ff-only
  else
    log "📥 Cloning $(basename "$dest")..."
    git clone "$repo" "$dest"
  fi
}

update_or_clone "https://github.com/zsh-users/zsh-autosuggestions" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
update_or_clone "https://github.com/zsh-users/zsh-syntax-highlighting" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# --- Set zsh as default shell if not already (interactive only) ---
CURRENT_SHELL="$(basename "${SHELL:-}")"
if [ "$CURRENT_SHELL" != "zsh" ]; then
  if [[ -t 1 ]]; then
    log "⚙️ Changing default shell to zsh..."
    chsh -s "$(command -v zsh)"
  else
    warn "Not running in an interactive shell; skipping chsh."
  fi
else
  log "✅ zsh is already the default shell"
fi

log "🎉 Bootstrap script completed successfully!"