# Install Node.js
volta install node
volta install npm

# Install npm packages
npm install -g aicommits

# Settings
source ~/.env
aicommits config set OPENAI_KEY=$OPENAI_KEY
