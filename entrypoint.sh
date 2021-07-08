#!/bin/sh -v

# Build Go Lambda handlers.
# Don't expect this command line to work on MacOS - the command line tools don't support all the options.
echo "Building Go Lambda functions..."
find . -type f -name "*main.go" | xargs --no-run-if-empty dirname | awk '{print "GOOS=linux GOARCH=amd64 go build -ldflags=\"-s -w\" -o "$1"/lambdaFunction "$1"/main.go\0"}' | sh

# Execute cdk commands.
echo "Executing CDK command..."
$1

# Say complete.
echo "Done."
