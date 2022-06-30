FROM alpine:latest as downloads

# Install curl.
RUN apk add curl

# https://explainshell.com/explain?cmd=curl+-fsSLO+example.org
WORKDIR /downloads
RUN curl -fsSLO https://download.docker.com/linux/debian/gpg
RUN curl -fsSL -o awscli_amd64.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.7.12.zip
RUN curl -fsSL -o awscli_arm64.zip https://awscli.amazonaws.com/awscli-exe-linux-aarch64-2.7.12.zip
RUN curl -fsSL -o go_amd64.tar.gz "https://go.dev/dl/go1.18.3.linux-amd64.tar.gz"
RUN curl -fsSL -o go_arm64.tar.gz "https://go.dev/dl/go1.18.3.linux-arm64.tar.gz"

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

# Install CDK.
RUN npm install -g aws-cdk@2.29.1 typescript

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

# Install eXeCute.
RUN go install github.com/joerdav/xc/cmd/xc@1fa51af1d295c716d51d551348d8948e21330d72

# Install gdiv.
RUN go install github.com/joe-davidson1802/gdiv/cmd/gdiv@c4a3eae7ff9d90f78eb91665d9bbd7dc57c49fe1

# Install gosec and staticcheck.
RUN go install github.com/securego/gosec/v2/cmd/gosec@1d909e2687abe43eaa81af88d6efde3d20c8d481
RUN go install honnef.co/go/tools/cmd/staticcheck@c8caa92bad8c27ae734c6725b8a04932d54a147b

# Install templ.
RUN go install github.com/a-h/templ/cmd/templ@220fc807ae592143116582cc13d61cd989ccb9e1

# JQ.
RUN apt-get install -y jq

# Clean up after any installs.
RUN apt-get clean

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

