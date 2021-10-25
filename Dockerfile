FROM node:latest

# Install CDK.
RUN npm install -g aws-cdk@1.125.0 typescript

# Install Go.
RUN curl -L -o go1.17.2.linux-amd64.tar.gz https://golang.org/dl/go1.17.2.linux-amd64.tar.gz 
RUN rm -rf /usr/local/go && tar -C /usr/local -xzf go1.17.2.linux-amd64.tar.gz
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

# Install eXeCute
RUN go install github.com/joe-davidson1802/xc/cmd/xc@v0.0.17

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
