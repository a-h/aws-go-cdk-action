FROM node:latest

# Install CDK.
RUN npm install -g aws-cdk@1.138.2 typescript

# Install Go.
RUN curl -L -o go1.17.5.linux-amd64.tar.gz https://go.dev/dl/go1.17.5.linux-amd64.tar.gz
RUN rm -rf /usr/local/go && tar -C /usr/local -xzf go1.17.5.linux-amd64.tar.gz
ENV PATH "$PATH:/usr/local/go/bin"
ENV PATH "$PATH:/root/go/bin"

# Install pact.
RUN curl -LO https://github.com/pact-foundation/pact-ruby-standalone/releases/download/v1.88.66/pact-1.88.66-linux-x86_64.tar.gz
RUN rm -rf /usr/local/pact && tar -C /usr/local -xzf pact-1.88.66-linux-x86_64.tar.gz
ENV PATH "$PATH:/usr/local/pact/bin"

# Install Docker.
RUN apt-get update && apt-get install -y apt-transport-https ca-certificates gnupg lsb-release
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io

## Instal AWS CLI

RUN mkdir -p /tmp/aws \
    && cd /tmp/aws \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install

# Install eXeCute
RUN go install github.com/joe-davidson1802/xc/cmd/xc@v0.0.45

# Install gdiv
RUN go install github.com/joe-davidson1802/gdiv/cmd/gdiv@v0.0.8

# Install gosec and staticcheck.
RUN go install github.com/securego/gosec/v2/cmd/gosec@latest
RUN go install honnef.co/go/tools/cmd/staticcheck@latest

# Install templ.
RUN go install github.com/a-h/templ/cmd/templ@latest

# Install wkhtmltopdf
RUN apt-get install -y xfonts-75dpi xfonts-base && \
   wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.buster_amd64.deb && \
   dpkg --install wkhtmltox_0.12.6-1.buster_amd64.deb

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
