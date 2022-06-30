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

```
docker build --progress=plain -t a-h/aws-go-cdk-action .
```

### setup-buildx

See https://cloudolife.com/2022/03/05/Infrastructure-as-Code-IaC/Container/Docker/Docker-buildx-support-multiple-architectures-images/ for information about building cross-platform images.

```
docker buildx create --name cross-platform
docker buildx use cross-platform
```

### build-cross-platform

```
docker buildx build -t ghcr.io/a-h/aws-go-cdk-action:latest --progress=plain --platform=linux/arm64,linux/amd64 .
```

### push-cross-platform

```
docker buildx build -t ghcr.io/a-h/aws-go-cdk-action:latest --progress=plain --push --platform=linux/arm64,linux/amd64 .
```
