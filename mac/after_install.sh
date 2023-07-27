# Install Node.js
volta install node
volta install npm

# Install packages
npm install -g @githubnext/github-copilot-cli

# setting git commit template
git config --global commit.template ~/.gitmessage
