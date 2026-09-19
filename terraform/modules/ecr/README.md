# AWS ECR Module

This module provisions Amazon Elastic Container Registry (ECR) repositories configured for secure microservice deployments.

## Features
- Dynamic provisioning of multiple named microservice repositories using `for_each`.
- Automated vulnerability scanning on image push (`scan_on_push = true`).
- Configurable tag mutability (`MUTABLE` for rapid iteration or `IMMUTABLE` for strict provenance).
- Automated lifecycle policies to purge untagged images and maintain only the latest 10 image versions.

## Usage in CI/CD (GitHub Actions / GitLab CI)
To push images to these repositories:
```bash
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin <REGISTRY_ID>.dkr.ecr.ap-south-1.amazonaws.com
docker build -t <REPOSITORY_URL>:latest .
docker push <REPOSITORY_URL>:latest
```
