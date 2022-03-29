ARG ALPINE_VERSION=3.15

FROM alpine:${ALPINE_VERSION}

ENV TERRAFORM_VERSION 1.1.7

RUN apk -v --no-cache --update add \
        libc6-compat \
        openssh-client \
        python3 \
        ca-certificates \
        groff \
        less \
        bash \
        make \
        curl \
        wget \
        zip \
        git \
        && \
    update-ca-certificates

RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools

RUN cd /usr/local/bin && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

VOLUME [ "/root/.aws" ]
VOLUME [ "/opt/app" ]

WORKDIR /opt/app

CMD ["terraform", "--version"]


