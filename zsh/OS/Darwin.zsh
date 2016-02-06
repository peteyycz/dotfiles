# ====================
# Boot2Docker config on OSX
# ====================
export DOCKER_HOST='tcp://192.168.59.103:2376'
export DOCKER_CERT_PATH='/Users/peteyy/.boot2docker/certs/boot2docker-vm'
export DOCKER_TLS_VERIFY=1

# ====================
# iTerm integration
# ====================
test -e ${HOME}/.iterm2_shell_integration.bash && source ${HOME}/.iterm2_shell_integration.bash

# ====================
# Node Version manager
# ====================
export NVM_DIR=$(brew --prefix nvm)
