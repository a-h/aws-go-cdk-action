FROM alpine:latest AS downloads

# Install curl.
RUN apk add curl

# https://explainshell.com/explain?cmd=curl+-fsSLO+example.org
WORKDIR /downloads
RUN curl -fsSLO https://download.docker.com/linux/debian/gpg
RUN curl -fsSLO https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.4.14.zip
RUN curl -fsSLO https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.buster_amd64.deb
RUN curl -fsSLO https://go.dev/dl/go1.17.5.linux-amd64.tar.gz
RUN curl -fsSLO https://github.com/pact-foundation/pact-ruby-standalone/releases/download/v1.88.66/pact-1.88.66-linux-x86_64.tar.gz

# Create a sum of all files.
RUN find . -type f -exec sha256sum {} \; >> /downloads/current_hashes.txt
RUN cat /downloads/current_hashes.txt

# Compare to past hashes.
COPY past_hashes.txt /downloads
RUN sha256sum -c past_hashes.txt

FROM node:16 
# Based on Debian buster.

COPY --from=downloads /downloads /downloads

# Install CDK.
RUN npm install -g aws-cdk@1.138.2 typescript

# Install Go.
RUN rm -rf /usr/local/go && tar -C /usr/local -xzf /downloads/go1.17.5.linux-amd64.tar.gz
ENV PATH "$PATH:/usr/local/go/bin"
ENV PATH "$PATH:/root/go/bin"

# Install pact.
RUN rm -rf /usr/local/pact && tar -C /usr/local -xzf /downloads/pact-1.88.66-linux-x86_64.tar.gz
ENV PATH "$PATH:/usr/local/pact/bin"

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
    unzip /downloads/awscli-exe-linux-x86_64-2.4.14.zip -d /tmp && \
    ./tmp/aws/install && \
    rm -rf /tmp/aws

# Install eXeCute
RUN go install github.com/joe-davidson1802/xc/cmd/xc@f8fb0eaab75ef7254a927dc7749f7aac0cae82ad

# Install gdiv
RUN go install github.com/joe-davidson1802/gdiv/cmd/gdiv@c4a3eae7ff9d90f78eb91665d9bbd7dc57c49fe1

# Install gogit
RUN go install github.com/joe-davidson1802/gogit/cmd/gogit@1c1b0ba9b0735f646ef833a746329fb03169c656

# Install gosec and staticcheck.
RUN go install github.com/securego/gosec/v2/cmd/gosec@1d909e2687abe43eaa81af88d6efde3d20c8d481
RUN go install honnef.co/go/tools/cmd/staticcheck@c8caa92bad8c27ae734c6725b8a04932d54a147b

# Install templ.
RUN go install github.com/a-h/templ/cmd/templ@220fc807ae592143116582cc13d61cd989ccb9e1

# Install wkhtmltopdf
RUN apt-get install -y xfonts-75dpi xfonts-base && \
  dpkg --install /downloads/wkhtmltox_0.12.6-1.buster_amd64.deb

# JQ.
RUN apt-get install -y jq

# Clean up after any installs.
RUN apt-get clean

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
