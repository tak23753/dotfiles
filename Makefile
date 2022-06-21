# Do everything.
all: init link defaults brew karabiner

# Set initial preference.
init:
	./init.sh

# Link dotfiles.
link:
	./link.sh

# Set macOS system preferences.
defaults:
	./defaults.sh

# Install macOS applications.
brew:
	./brew.sh

karabiner:
	./karabiner.sh
