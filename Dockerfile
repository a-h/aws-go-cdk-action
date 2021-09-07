FROM node:latest

# Install CDK.
RUN npm install -g aws-cdk

# Install Go.
RUN curl -L -o go1.16.6.linux-amd64.tar.gz https://golang.org/dl/go1.16.6.linux-amd64.tar.gz 
RUN rm -rf /usr/local/go && tar -C /usr/local -xzf go1.16.6.linux-amd64.tar.gz
ENV PATH "$PATH:/usr/local/go/bin"

# Install pact.
RUN curl -LO https://github.com/pact-foundation/pact-ruby-standalone/releases/download/v1.88.64/pact-1.88.64-osx.tar.gz
RUN rm -rf /usr/local/pact && tar -C /usr/local -xzf pact-1.88.64-osx.tar.gz
ENV PATH "$PATH:/usr/local/pact/bin"

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
