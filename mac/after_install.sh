# Install Node.js
volta install node
volta install npm

# Install npm packages
npm install -g @githubnext/github-copilot-cli

# setting git commit template
git config --global commit.template ~/.gitmessage

# Install kubectl_aliases
if [ ! -f ~/.kubectl_aliases ]; then
  curl "https://raw.githubusercontent.com/ahmetb/kubectl-aliases/master/.kubectl_aliases" -o ~/.kubectl_aliases
fi

# Install gke-gcloud-auth-plugin
gcloud components install gke-gcloud-auth-plugin

# Install asdf plugins
asdf plugin-add kubectl https://github.com/asdf-community/asdf-kubectl.git
asdf install kubectl latest
asdf global kubectl latest
asdf plugin-add kubectx https://github.com/virtualstaticvoid/asdf-kubectx.git
asdf install kubectx latest
asdf global kubectx latest
