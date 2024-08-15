FROM ghcr.io/epicgames/unreal-engine:dev-5.3.1

# Pass arguments which defines the user and group
ARG DOCKER_USER
ARG UID
ARG GID

# Start as root
USER root

# Create the group if it doesn't exist
RUN groupadd -g ${GID} ${DOCKER_USER} || true

# Create a new user with a home directory and same UID and GID as the host user
RUN useradd -m -u $UID -g $GID $DOCKER_USER

# Set the password of the new user to 'password'
RUN echo "$DOCKER_USER:password" | chpasswd

# Add the user to the sudo group
RUN usermod -aG sudo $DOCKER_USER
RUN echo "$DOCKER_USER ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers

# Set the default shell to bash
RUN chsh -s /bin/bash $DOCKER_USER

# Move the Unreal Engine directory to the root directory
RUN mv /home/ue4/UnrealEngine /UnrealEngine

# Change the owner of the Unreal Engine directory to the new user
RUN chown -R $DOCKER_USER:$DOCKER_USER /UnrealEngine

# Set the user
USER $DOCKER_USER

# Create custom command for opening the Unreal Editor
COPY ./commands/unreal-editor /usr/local/bin/unreal-editor
RUN sudo chmod +x /usr/local/bin/unreal-editor

# Install VS Code
RUN sudo apt-get update && sudo apt-get install -y curl
RUN curl -L https://go.microsoft.com/fwlink/?LinkID=760868 -o /tmp/vscode.deb
RUN sudo apt install -y /tmp/vscode.deb

# Set the working directory
WORKDIR /home/$DOCKER_USER
