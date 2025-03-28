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
else
    echo "Homebrew is already installed."
fi

# Restarting SHELL
## MOVED TO END

# Move to MacOS_dot-files
cd ./MacOS_dot-files

brew install stow
stow . --adopt


# Restarting SHELL
echo "Restarting the shell..."
exec $SHELL