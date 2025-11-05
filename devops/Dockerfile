# Base Stage: Use a minimal Alpine base for downloading tools
FROM alpine:3.21.3 AS build

# Set versions for tools
ENV TERRAFORM_VERSION=1.2.3
ENV TERRAGRUNT_VERSION=0.28.24
ARG KUBECTL_VERSION=1.32.3
ARG KUSTOMIZE_VERSION=5.6.0
ARG TARGET_OS=linux
ARG TARGET_ARCH=amd64

# Create tools directory for collection
RUN mkdir /tools

# Install basic utilities for the build process including openssl
RUN apk add --no-cache curl unzip tar bash openssl

# Download and set up Terraform
RUN curl -fsSL -o terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${TARGET_OS}_${TARGET_ARCH}.zip \
    && unzip terraform.zip -d /tools \
    && chmod +x /tools/terraform \
    && rm terraform.zip

# Download and set up Terragrunt
RUN curl -fsSL https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_${TARGET_OS}_${TARGET_ARCH} \
    -o /tools/terragrunt \
    && chmod +x /tools/terragrunt

# Download and set up Kubectl
RUN curl -fsSL -o kubectl https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/${TARGET_OS}/${TARGET_ARCH}/kubectl \
    && chmod +x kubectl \
    && mv kubectl /tools/kubectl

# Download and set up Kustomize
RUN curl -fsSL https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_${TARGET_OS}_${TARGET_ARCH}.tar.gz \
    | tar xz -C /tools \
    && chmod +x /tools/kustomize

# Download and set up Helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
    && chmod +x get_helm.sh \
    && ./get_helm.sh \
    && mv /usr/local/bin/helm /tools/helm \
    && rm get_helm.sh


# Final Stage: Start with a clean Python Alpine base
FROM python:3.9.22-alpine3.21 AS final

# Copy tools from the build stage
COPY --from=build /tools/* /usr/local/bin/

# Install runtime dependencies required for the tools and environment
RUN apk add --no-cache libc6-compat openssh openssl less bash make curl wget git zip unzip zsh jq aws-cli \
    && rm -rf /var/cache/apk/*

# Create SSH directory for Bitbucket access and set up known hosts
RUN mkdir -p /root/.ssh/ \
    && touch /root/.ssh/known_hosts \
    && ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts

# Copy SSH key for Bitbucket access (make sure to manage this securely)
ADD id_ed25519 /root/.ssh/id_ed25519

# Add AWS and Kubernetes environment variables to .zshrc
RUN echo 'export PS1="🐳 %F{yellow}$DOCKER_CONTAINER_NAME%f %~ # "' > ~/.zshrc \
    && echo 'export AWS_PROFILE=tf' >> ~/.zshrc \
    && echo 'export KUBE_CONFIG_PATH=/root/.kube/config' >> ~/.zshrc

# Define volumes for AWS and Kubernetes configurations to persist data
VOLUME [ "/root/.aws", "/root/.kube", "/opt/modules", "/opt/live" ]

# Set the working directory for subsequent commands
WORKDIR /opt/live

# Specify the default command to run when the container starts
CMD [ "zsh" ]
