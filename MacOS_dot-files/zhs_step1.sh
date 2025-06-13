#!/bin/zsh
## zhs_step1.sh

# Start in $HOME
cd $HOME

# Make sure files exists
## .zshenv
filename=".zshenv"
[ ! -f "$filename" ] && touch "$filename" && echo "File created" || echo "File exists"

# Check if brew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing..."

## Download and install brew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

## Add the brew command to the profile 
	echo >> $HOME/.zshenv
	echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zshenv

## Move to MacOS_dot-files
	cd ./MacOS_dot-files
	brew install stow
	stow . --adopt    
else
    echo "Homebrew is already installed."
fi


# Brew install applications
brew install --cask discord
brew install --cask slack
brew install --cask bbedit
brew install --cask visual-studio-code
brew install --cask firefox
brew install --cask google-chrome
brew install --cask docker
brew install --cask tiles
brew install --cask vlc

## Work applications 
brew install --cask microsoft-outlook
brew install --cask microsoft-word
brew install --cask microsoft-teams
brew install --cask sqlpro-for-mysql
brew install --cask zoom

### Advanced applications
brew install --cask open-video-downloader
brew install --cask tailscale


# Restarting SHELL
echo "Restarting the shell..."
exec $SHELL