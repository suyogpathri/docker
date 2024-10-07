# Base Stage: Use a minimal Alpine base for downloading tools
FROM alpine:3.20.3 AS build

# Set versions for tools
ENV TERRAFORM_VERSION=1.2.3
ENV TERRAGRUNT_VERSION=0.28.24
ARG KUBECTL_VERSION=1.31.1
ARG KUSTOMIZE_VERSION=5.4.3
ARG HELM_VERSION=3.15.3
ARG TARGET_OS=linux
ARG TARGET_ARCH=amd64

# Install basic utilities for the build process including openssl
RUN apk add --no-cache curl unzip tar bash openssl

# Download and verify Terraform checksum
RUN curl -sS -L -O https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${TARGET_OS}_${TARGET_ARCH}.zip \
    && unzip terraform_${TERRAFORM_VERSION}_${TARGET_OS}_${TARGET_ARCH}.zip \
    && chmod +x terraform

# Download Terragrunt
RUN curl -sS -L https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_${TARGET_OS}_${TARGET_ARCH} \
    -o terragrunt \
    && chmod +x terragrunt

# Download Kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/${TARGET_OS}/amd64/kubectl \
    && chmod +x kubectl

# Download Kustomize
RUN curl -fL https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_${TARGET_OS}_${TARGET_ARCH}.tar.gz \
    | tar xz \
    && chmod +x kustomize

# Download Helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
    && chmod +x get_helm.sh \
    && ./get_helm.sh


# Final Stage: Start with a clean Python Alpine base
FROM python:alpine3.20 AS final

# Copy tools from the build stage
COPY --from=build /terraform /usr/local/bin/terraform
COPY --from=build /terragrunt /usr/local/bin/terragrunt
COPY --from=build /kubectl /usr/local/bin/kubectl
COPY --from=build /kustomize /usr/local/bin/kustomize

# Install runtime dependencies required for the tools and environment
RUN apk add --no-cache libc6-compat openssh openssl less bash make curl wget git zip unzip zsh jq aws-cli \
 && echo 'export PS1="🐳 %F{yellow}$DOCKER_CONTAINER_NAME%f %~ # "' > ~/.zshrc

# Create SSH directory for Bitbucket access and set up known hosts
RUN mkdir -p /root/.ssh/ \
    && touch /root/.ssh/known_hosts \
    && ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts

# Copy SSH key for Bitbucket access (make sure to manage this securely)
ADD id_rsa /root/.ssh/id_rsa

# Add AWS and Kubernetes environment variables to .zshrc
RUN echo 'export AWS_PROFILE=tf' >> ~/.zshrc \
    && echo 'export KUBE_CONFIG_PATH=/root/.kube/config' >> ~/.zshrc


# Define volumes for AWS and Kubernetes configurations to persist data
VOLUME [ "/root/.aws", "/root/.kube", "/opt/module", "/opt/live" ]

# Set the working directory for subsequent commands
WORKDIR /opt/live

# Specify the default command to run when the container starts
CMD [ "zsh" ]
