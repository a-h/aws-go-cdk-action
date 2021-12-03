# AWS Go CDK action

This action runs CDK deploy for Go projects.

The Docker image is also deployed to Github Docker registry.

## Inputs

## `command`

The command to execute (defaults to `cdk deploy`).

## Example usage

```yaml
uses: a-h/aws-go-cdk-action@v1
with:
  command: 'cdk deploy'
env:
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

## Tasks

### build

```sh
docker build -t aws-go-cdk-action:latest .
```

### run

```sh
docker run -it --rm aws-go-cdk-action:latest /bin/bash
```
