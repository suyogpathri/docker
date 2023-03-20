ARG ALPINE_VERSION=3.17

FROM alpine:${ALPINE_VERSION}

# Tools version
ENV TERRAFORM_VERSION=1.2.3
ENV TERRAGRUNT_VERSION=0.28.24
ENV KUBECTL_VERSION=1.26.1
ENV KUSTOMIZE_VERSION=4.5.7
ENV HELM_VERSION=3.11.0

# OS & Architecture
ENV TARGET_OS=linux
ENV TARGET_ARCH=amd64


RUN apk -v --no-cache --update add \
    libc6-compat \
    openssh \
    openssl \
    ca-certificates \
    less \
    bash \
    make \
    curl \
    wget \
    zip \
    unzip \
    git

RUN apk add --no-cache \
    zsh \
    python3 \
    py3-pip \
    && pip3 install --upgrade pip \
    && pip3 install --no-cache-dir \
        awscli \
    && rm -rf /var/cache/apk/*

RUN echo 'export PS1="🐳 %F{blue}$DOCKER_CONTAINER_NAME%f %~ # "' > ~/.zshrc

# Copy the SSH Key for bitbucket access
RUN mkdir /root/.ssh/

ADD id_rsa /root/.ssh/id_rsa

RUN touch /root/.ssh/known_hosts

RUN ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts

# Install Terraform
RUN curl -sS -L -O \
        https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${TARGET_OS}_${TARGET_ARCH}.zip \
    && unzip terraform_${TERRAFORM_VERSION}_${TARGET_OS}_${TARGET_ARCH}.zip \
    && chmod +x ./terraform \
    && mv terraform /usr/local/bin/

# Install Terragrunt
RUN curl -sS -L https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_${TARGET_OS}_${TARGET_ARCH} \
        -o /usr/local/bin/terragrunt \
    && chmod +x /usr/local/bin/terragrunt

# Install Kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/${TARGET_OS}/amd64/kubectl \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin

# Install Kustomize
RUN set -ex; \
    curl -fL https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_${TARGET_OS}_${TARGET_ARCH}.tar.gz | tar xz && \
    chmod +x kustomize \
    && mv ./kustomize /usr/local/bin

# Install helm-3
RUN set -ex; \
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
    && chmod 700 get_helm.sh \
    && ./get_helm.sh

VOLUME [ "/root/.aws" ]
VOLUME [ "/root/.kube" ]
VOLUME [ "/opt/module" ]
VOLUME [ "/opt/live" ]

WORKDIR /opt/
CMD [ "zsh"]
