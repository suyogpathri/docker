ARG ALPINE_VERSION=3.15

FROM alpine:${ALPINE_VERSION}

ENV TERRAFORM_VERSION 1.2.8
ENV TERRAGRUNT_VERSION v0.28.24

RUN apk -v --no-cache --update add \
        libc6-compat \
        openssh \
        ca-certificates \
        python2 \
        less \
        bash \
        make \
        curl \
        wget \
        zip \
        unzip \
        git \
        && \
    update-ca-certificates

RUN apk add --no-cache \
        python3 \
        py3-pip \
    && pip3 install --upgrade pip \
    && pip3 install --no-cache-dir \
        awscli \
    && rm -rf /var/cache/apk/*

RUN aws --version   # Just to make sure its installed alright

# Copy the SSH Key for bitbucket access
RUN mkdir /root/.ssh/

ADD id_rsa /root/.ssh/id_rsa

RUN touch /root/.ssh/known_hosts

RUN ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts

# Install Terraform 
RUN curl -sS -L -O \
        https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /usr/bin/terraform \
    && chmod +x /usr/bin/terraform

# Just to make sure its installed alright
RUN terraform --version

# Install Terragrunt
RUN cd /usr/bin && \
    curl -sS -L https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 \
        -o /usr/bin/terragrunt \
    && chmod +x /usr/bin/terragrunt

# Just to make sure its installed alright
RUN terragrunt --version

VOLUME [ "/root/.aws" ]
VOLUME [ "/opt/module" ]
VOLUME [ "/opt/live" ]

WORKDIR /opt/

