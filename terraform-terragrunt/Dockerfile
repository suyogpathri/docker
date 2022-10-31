ARG ALPINE_VERSION=3.15

FROM alpine:${ALPINE_VERSION}

ENV TERRAFORM_VERSION 1.2.8
ENV TERRAGRUNT_VERSION v0.28.24

RUN apk -v --no-cache --update add \
        libc6-compat \
        python2 \
        less \
        bash \
        make \
        curl \
        wget \
        zip \
        git \
        openssh

RUN python -m ensurepip
RUN pip install --no-cache --upgrade pip setuptools

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


# Install Terragrunt
RUN cd /usr/bin && \
    curl -sS -L https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 \
        -o /usr/bin/terragrunt \
    && chmod +x /usr/bin/terragrunt


VOLUME [ "/root/.aws" ]
VOLUME [ "/opt/module" ]
VOLUME [ "/opt/live" ]

WORKDIR /opt/

CMD ["terraform", "--version"]
CMD ["terragrunt", "--version"]


