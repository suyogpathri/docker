# DevOps Tools Container
# Includes: Terraform, Terragrunt, kubectl, kustomize, Helm, kubeswitch, AWS CLI v2
#
# Build:
#   docker build -t devops-tools:latest .
#
# Run with bind mounts (recommended):
#   docker run -it \
#     -v ~/.aws:/root/.aws \
#     -v ~/.kube:/root/.kube \
#     -v ~/.devops_history:/root/.zsh_history_data \
#     -v $(pwd):/opt/live \
#     -e DOCKER_CONTAINER_NAME="devops" \
#     devops-tools:latest
#
# Architecture: Supports both amd64 and arm64 (Apple Silicon)

# Base Stage: Use a minimal Alpine base for downloading tools
FROM alpine:3.23 AS build

# Set versions for tools
ENV TERRAFORM_VERSION=1.2.3
ENV TERRAGRUNT_VERSION=0.28.24
ARG KUBECTL_VERSION=1.35.0
ARG KUSTOMIZE_VERSION=5.8.0
ARG HELM_VERSION=4.1.0
ARG KUBESWITCH_VERSION=0.9.3

# Use Docker's built-in platform arguments for automatic architecture detection
ARG TARGETARCH
ARG TARGETOS

# Install build utilities and download all tools in a single layer
RUN apk add --no-cache curl unzip tar bash openssl binutils && \
    mkdir /tools && \
    # Terraform
    curl -fsSL -o terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${TARGETOS}_${TARGETARCH}.zip && \
    unzip -q terraform.zip -d /tools && \
    rm terraform.zip && \
    # Terragrunt
    curl -fsSL -o /tools/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_${TARGETOS}_${TARGETARCH} && \
    # Kubectl
    curl -fsSL -o /tools/kubectl https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/${TARGETOS}/${TARGETARCH}/kubectl && \
    # Kustomize
    curl -fsSL https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_${TARGETOS}_${TARGETARCH}.tar.gz | tar xz -C /tools && \
    # Helm
    curl -fsSL -o helm.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz && \
    tar -zxf helm.tar.gz && \
    mv ${TARGETOS}-${TARGETARCH}/helm /tools/helm && \
    rm -rf helm.tar.gz ${TARGETOS}-${TARGETARCH} && \
    # Kubeswitch
    curl -fsSL -o /tools/switcher https://github.com/danielfoehrKn/kubeswitch/releases/download/${KUBESWITCH_VERSION}/switcher_${TARGETOS}_${TARGETARCH} && \
    # Make all tools executable
    chmod +x /tools/* && \
    # Strip binaries to reduce size (removes debug symbols)
    strip /tools/* 2>/dev/null || true

# Install AWS CLI v2 via pip (works natively on Alpine without glibc)
RUN apk add --no-cache python3 py3-pip && \
    pip3 install --no-cache-dir --break-system-packages awscli && \
    # Clean up pip cache
    rm -rf /root/.cache/pip


# Final Stage: Start with a minimal Alpine base
FROM alpine:3.23 AS final

# Copy tools from the build stage
COPY --from=build /tools/* /usr/local/bin/
COPY --from=build /usr/lib/python3.12 /usr/lib/python3.12
COPY --from=build /usr/bin/aws /usr/bin/aws

# Install only essential runtime dependencies
RUN apk add --no-cache \
    ca-certificates \
    libc6-compat \
    openssh-client \
    git \
    curl \
    zsh \
    jq \
    python3 && \
    rm -rf /var/cache/apk/* && \
    # Create SSH directory and configure known hosts
    mkdir -p /root/.ssh/ && \
    touch /root/.ssh/known_hosts && \
    ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts && \
    # Create directory for persistent shell history
    mkdir -p /root/.zsh_history_data && \
    # Configure zsh
    echo 'export PS1="🐳 %F{yellow}$DOCKER_CONTAINER_NAME%f %~ # "' > ~/.zshrc && \
    echo 'export AWS_PROFILE=tf' >> ~/.zshrc && \
    echo 'export KUBE_CONFIG_PATH=/root/.kube/config' >> ~/.zshrc && \
    echo '' >> ~/.zshrc && \
    echo '# Zsh History Configuration' >> ~/.zshrc && \
    echo 'export HISTFILE=/root/.zsh_history_data/.zsh_history' >> ~/.zshrc && \
    echo 'export HISTSIZE=10000' >> ~/.zshrc && \
    echo 'export SAVEHIST=10000' >> ~/.zshrc && \
    echo 'setopt APPEND_HISTORY' >> ~/.zshrc && \
    echo 'setopt SHARE_HISTORY' >> ~/.zshrc && \
    echo 'setopt HIST_IGNORE_DUPS' >> ~/.zshrc && \
    echo 'setopt HIST_IGNORE_ALL_DUPS' >> ~/.zshrc && \
    echo 'setopt HIST_FIND_NO_DUPS' >> ~/.zshrc && \
    echo 'setopt HIST_SAVE_NO_DUPS' >> ~/.zshrc && \
    echo 'setopt HIST_EXPIRE_DUPS_FIRST' >> ~/.zshrc && \
    echo 'setopt HIST_IGNORE_SPACE' >> ~/.zshrc && \
    echo 'setopt HIST_REDUCE_BLANKS' >> ~/.zshrc && \
    echo 'setopt INC_APPEND_HISTORY' >> ~/.zshrc && \
    echo '' >> ~/.zshrc && \
    echo '# Initialize zsh completion system' >> ~/.zshrc && \
    echo 'autoload -Uz compinit && compinit' >> ~/.zshrc && \
    echo '' >> ~/.zshrc && \
    echo '# Kubeswitch configuration' >> ~/.zshrc && \
    echo 'if command -v switcher &> /dev/null; then' >> ~/.zshrc && \
    echo '  source <(switcher init zsh)' >> ~/.zshrc && \
    echo '  source <(switcher completion zsh)' >> ~/.zshrc && \
    echo '  alias s=switch' >> ~/.zshrc && \
    echo 'fi' >> ~/.zshrc

# Copy SSH key for Bitbucket access (make sure to manage this securely)
ADD id_ed25519 /root/.ssh/id_ed25519

# Define volumes for AWS and Kubernetes configurations to persist data
# Usage with bind mounts (recommended):
#   docker run -it \
#     -v ~/.aws:/root/.aws \
#     -v ~/.kube:/root/.kube \
#     -v ~/.devops_history:/root/.zsh_history_data \
#     -v $(pwd):/opt/live \
#     -e DOCKER_CONTAINER_NAME="devops" \
#     devops-tools:latest
#
# Alternative with named volume:
#   docker run -it \
#     -v ~/.aws:/root/.aws \
#     -v ~/.kube:/root/.kube \
#     -v devops-history:/root/.zsh_history_data \
#     -v $(pwd):/opt/live \
#     -e DOCKER_CONTAINER_NAME="devops" \
#     devops-tools:latest
VOLUME [ "/root/.aws", "/root/.kube", "/root/.zsh_history_data", "/opt/modules", "/opt/live" ]

# Set the working directory for subsequent commands
WORKDIR /opt/live

# Specify the default command to run when the container starts
CMD [ "zsh" ]
