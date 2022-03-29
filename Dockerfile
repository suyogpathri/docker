ARG ALPINE_VERSION=3.15
FROM alpine:${ALPINE_VERSION}

ENV AWS_CDK_VERSION 2.17.0

RUN apk -v --no-cache --update add \
        nodejs \
        npm \
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
RUN npm install -g aws-cdk@${AWS_CDK_VERSION}

VOLUME [ "/root/.aws" ]
VOLUME [ "/opt/app" ]

# Allow for caching python modules
VOLUME ["/usr/lib/python3.10/site-packages/"]

WORKDIR /opt/app

CMD ["cdk", "--version"]
