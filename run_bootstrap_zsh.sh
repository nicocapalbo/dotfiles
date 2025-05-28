#!/bin/bash
set -euo pipefail

echo "🚀 Starting bootstrap script..."

# Helper to print errors
err() {
  echo "❌ Error: $*" >&2
  exit 1
}

# Check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Install Zsh if missing
if ! command_exists zsh; then
  echo "🔧 Installing zsh..."
  if command_exists apt; then
    sudo apt update && sudo apt install -y zsh
  elif command_exists brew; then
    brew install zsh
  else
    err "No known package manager to install zsh"
  fi
else
  echo "✅ zsh already installed"
fi

# Install Git if missing (needed for plugins)
if ! command_exists git; then
  echo "🔧 Installing git..."
  if command_exists apt; then
    sudo apt update && sudo apt install -y git
  elif command_exists brew; then
    brew install git
  else
    err "No known package manager to install git"
  fi
else
  echo "✅ git already installed"
fi

# Install curl if missing (needed for Oh My Zsh install)
if ! command_exists curl; then
  echo "🔧 Installing curl..."
  if command_exists apt; then
    sudo apt update && sudo apt install -y curl
  elif command_exists brew; then
    brew install curl
  else
    err "No known package manager to install curl"
  fi
else
  echo "✅ curl already installed"
fi

ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"

# Install Oh My Zsh if missing
if [ ! -s "$ZSH_DIR/oh-my-zsh.sh" ]; then
  echo "📦 Installing Oh My Zsh..."
  export RUNZSH=no
  export CHSH=no
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "✅ Oh My Zsh already installed"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH_DIR/custom}"

# Clone zsh-autosuggestions plugin
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  echo "📥 Cloning zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
  echo "✅ zsh-autosuggestions already installed"
fi

# Clone zsh-syntax-highlighting plugin
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  echo "📥 Cloning zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
  echo "✅ zsh-syntax-highlighting already installed"
fi

# Set zsh as default shell if not already
CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" != "zsh" ]; then
  echo "⚙️ Changing default shell to zsh..."
  chsh -s "$(command -v zsh)"
else
  echo "✅ zsh is already the default shell"
fi

echo "🎉 Bootstrap script completed successfully!"