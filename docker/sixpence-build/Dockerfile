FROM ubuntu:24.04

# Arguments
ARG user
ARG git_user
ARG git_email

ARG python_ver=3.13.1

# System
## LANG and TZ
# ENV LANUAGE=en_US
# ENV LC_ALL=utf8
ENV LANG=en_US.utf8
RUN ln -nfs /usr/share/zoneinfo/EST5EDT /etc/localtime

# Required Packages
RUN apt update && \
    apt install -y curl git ninja-build cmake clang pkg-config libgtk-3-dev vim openssh-client net-tools sudo libreadline-dev libssh-dev libsqlite3-dev libbzip3-dev libzlcore-dev locales

# Update Locale
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

# Add User & User Stuff
## Create user
RUN useradd --groups root ${user}

## Copy User Files
COPY --chown="${user}:${user}" user_files/dot-bashrc /home/${user}/.bashrc
COPY --chown="${user}:${user}" user_files/dot-bash_profile /home/${user}/.bash_profile
COPY --chown="${user}:${user}" user_files/dot-ssh-id_rsa /home/${user}/.ssh/id_rsa
COPY --chown="${user}:${user}" files/ssh-config /home/${user}/.ssh/config

## Enable sudo access
RUN echo "${user} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${user}

# User Specific
USER ${user}
WORKDIR /home/${user}

# Git
ENV GIT_AUTHOR_NAME=${git_user}
ENV GIT_AUTHOR_EMAIL=${git_email}
ENV GIT_COMMITTER_NAME=${git_user}
ENV GIT_COMMITTER_EMAIL=${git_email}

# PyEnv
RUN curl https://pyenv.run | bash
ENV PYENV_ROOT="/home/${user}/.pyenv"
ENV PATH="$PYENV_ROOT/bin:$PATH"

# Install Python and a `default` virtual env
RUN eval "$(pyenv init --path)"              \
    && eval "$(pyenv init -)"                \
    && pyenv update                          \
    && pyenv install ${python_ver}           \
    # DEFAULT virtual env
    && pyenv virtualenv ${python_ver} default  \
    # set the default python(s)
    && pyenv global default

# Sixpence
RUN git clone git@github.com:ccaroon/sixpence.git
WORKDIR /home/${user}/sixpence
RUN eval "$(pyenv init --path)"                     \
    && eval "$(pyenv init -)"                       \
    && pyenv local default                          \
    && python -mpip install -U pip wheel            \
    && python -mpip install -r requirements-dev.txt

####################################
# Set Default Start-up User and Dir
####################################
USER ${user}
WORKDIR /home/${user}
####################################
