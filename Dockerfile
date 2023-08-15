FROM alpine:latest AS downloads

# Install curl.
RUN apk add curl

# https://explainshell.com/explain?cmd=curl+-fsSLO+example.org
WORKDIR /downloads
RUN curl -fsSLO https://download.docker.com/linux/debian/gpg
RUN curl -fsSL -o awscli_amd64.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.9.12.zip
RUN curl -fsSL -o awscli_arm64.zip https://awscli.amazonaws.com/awscli-exe-linux-aarch64-2.9.12.zip
RUN curl -fsSL -o go_amd64.tar.gz "https://go.dev/dl/go1.19.4.linux-amd64.tar.gz"
RUN curl -fsSL -o go_arm64.tar.gz "https://go.dev/dl/go1.19.4.linux-arm64.tar.gz"
RUN curl -fsSL -o wkhtmltox_amd64.deb https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.buster_amd64.deb
RUN curl -fsSL -o wkhtmltox_arm64.deb https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.buster_arm64.deb

# Create a sum of all files.
RUN find . -type f -exec sha256sum {} \; >> /downloads/current_hashes.txt
RUN cat /downloads/current_hashes.txt

# Compare to past hashes.
COPY past_hashes.txt /downloads
RUN sha256sum -c past_hashes.txt

FROM node:16 
# Based on Debian buster.

COPY --from=downloads /downloads /downloads

# Use the specific architectures.
RUN mv "/downloads/awscli_$(dpkg --print-architecture).zip" /downloads/awscli.zip
RUN mv "/downloads/go_$(dpkg --print-architecture).tar.gz" /downloads/go.tar.gz
RUN mv "/downloads/wkhtmltox_$(dpkg --print-architecture).deb" /downloads/wkhtmltox.deb

# https://github.com/actions/runner/issues/691
# https://stackoverflow.com/questions/67748017/how-to-use-github-actions-checkoutv2-inside-own-docker-container
RUN groupadd -g 121 docker
RUN useradd -g docker runner
RUN usermod -a -G sudo runner
RUN usermod -a -G docker node

# Install CDK.
RUN npm install -g aws-cdk@2.89.0 typescript

# Install Go.
RUN rm -rf /usr/local/go && tar -C /usr/local -xzf /downloads/go.tar.gz
ENV PATH "$PATH:/usr/local/go/bin"
ENV PATH "$PATH:/root/go/bin"

# Update.
RUN apt-get update 

# Install Docker.
RUN apt-get install -y apt-transport-https ca-certificates gnupg lsb-release
RUN cat /downloads/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
# Need to update again after updating the key ring.
RUN apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io

## Install AWS CLI.
RUN mkdir -p /tmp && \
    unzip /downloads/awscli.zip -d /tmp && \
    ./tmp/aws/install && \
    rm -rf /tmp/aws

# Install eXeCute
RUN go install github.com/joerdav/xc/cmd/xc@72f8c2aa4fb993b436c9297590f613ed2f24513f

# Install gdiv
RUN go install github.com/joerdav/gdiv/cmd/gdiv@1ce83542a735a7815d712ed7165e8e4b60a46f77

# Install gogit
RUN go install github.com/joerdav/gogit/cmd/gogit@4d714937e5dbcc8d6bfe7ba02a46bd3d2d61b6a8

# Install gosec and staticcheck.
RUN curl -sfL https://raw.githubusercontent.com/securego/gosec/master/install.sh | sh -s v2.16.0
RUN go install honnef.co/go/tools/cmd/staticcheck@v0.4.3
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.53.2

# Install templ.
RUN go install github.com/a-h/templ/cmd/templ@1c6c2c9c3a5d354a026789da34405f900d5e44b5

# Install wkhtmltopdf
RUN apt-get install -y xfonts-75dpi xfonts-base && \
  dpkg --install /downloads/wkhtmltox.deb

# JQ.
RUN apt-get install -y jq

# Git
RUN apt-get install -y git

# Workaround for https://github.com/golang/go/issues/51253,https://github.com/actions/checkout/issues/760, to allow all repos to build
# The CVE isn't relevant to our github actions runners
COPY gitconfig /etc/gitconfig
RUN chgrp -R docker /etc/gitconfig

# Clean up after any installs.
RUN apt-get clean

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
