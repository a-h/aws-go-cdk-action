FROM node:latest

# Install CDK.
RUN npm install -g aws-cdk

# Install Go.
RUN curl -L -o go1.16.6.linux-amd64.tar.gz https://golang.org/dl/go1.16.6.linux-amd64.tar.gz 
RUN rm -rf /usr/local/go && tar -C /usr/local -xzf go1.16.6.linux-amd64.tar.gz
ENV PATH "$PATH:/usr/local/go/bin"

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
