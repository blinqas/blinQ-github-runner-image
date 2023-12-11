# GitHub Runner Container Image 🏃‍♂️🐳

## Table of Contents

- [GitHub Runner Container Image 🏃‍♂️🐳](#github-runner-container-image-️)
  - [Table of Contents](#table-of-contents)
  - [Introduction 📚](#introduction-)
  - [Quick Start 🚀](#quick-start-)
  - [What's Installed 🛠️](#whats-installed-️)
  - [Example deployment using The Image on Azure Container App 🚀](#example-deployment-using-the-image-on-azure-container-app-)
    - [Environment Variables 🔐](#environment-variables-)
  - [Github Token Scope](#github-token-scope)

## Introduction 📚

This repository contains the files required to build a Docker image designed to host self-hosted runners for GitHub Actions on the Azure cloud. The image is updated every Sunday at 12:00 UTC. Built upon the [myoung34/github-runner:ubuntu-jammy](https://github.com/myoung34/docker-github-actions-runner) base image, it extends its functionality by incorporating various development and runtime environments, including the Azure CLI, .NET, PowerShell, and more.
## Quick Start 🚀

Pull the latest image with `docker pull ghcr.io/blinqas/github_runner:latest`. To run it with the required environment variables, use:

```bash
docker run -d --name github-runner \
  -e RUNNER_NAME_PREFIX=your_prefix \
  -e ACCESS_TOKEN=your_access_token \
  -e RUNNER_SCOPE=org \
  -e ORG_NAME=your_org_name \
  ghcr.io/blinqas/github_runner:latest
```

The image is mainly target against Azure and is updated every Sunday at 12:00 UTC. It can be found on GitHub Packages at [this link](https://github.com/blinqas/blinQ_github_runner_image/pkgs/container/github_runner). 

## What's Installed 🛠️

The following table provides details about the software and frameworks installed in this container image:

| Software/Framework | Version       | Purpose                      |
| ------------------ | ------------- | ---------------------------- |
| Ubuntu             | jammy (22.04) | Base OS                      |
| NodeJS             | 20.x          | JavaScript runtime           |
| PowerShell         | Latest        | Shell environment            |
| .NET SDK           | 6.x, 7.0.111  | .NET SDK environments        |
| Azure CLI          | 2.52.0        | Azure command-line interface |
| Az PowerShell      | Latest        | Azure PowerShell module      |
| Az PowerShell      | Latest        | Azure PowerShell module      |
## Example deployment using The Image on Azure Container App 🚀

Below is an example Terraform code that deploys this container as a runner on Azure Container App. You would also need an existing container app environment.

```hcl
resource "azurerm_container_app" "runner" {
  name                         = "ca-${var.project_name}-${local.environment_name}"
  container_app_environment_id = azurerm_container_app_environment.runner_env.id
  resource_group_name          = data.azurerm_resource_group.deployment.name
  revision_mode                = "Single"
  tags                         = local.tags

  template {
    min_replicas = 1
    max_replicas = 1

    container {
      name   = "github-runner-01"
      image  = "ghcr.io/blinqas/github_runner:latest"
      cpu    = 2
      memory = "4Gi"

      env {
        name  = "RUNNER_NAME_PREFIX"
        value = "github-runner"
      }
      env {
        name        = "ACCESS_TOKEN"
        secret_name = "github-access-token"
      }
      env {
        name  = "RUNNER_SCOPE"
        value = "org"
      }
      env {
        name  = "ORG_NAME"
        value = "yourGithubOrgName"
      }
    }
  }

  secret {
    name  = "github-access-token"
    value = var.github_token
  }
}
```

### Environment Variables 🔐

The following environment variables should be set if you want to setup the runner for an organization:


- RUNNER_NAME_PREFIX: Prefix for the GitHub runner.
- ACCESS_TOKEN: GitHub Access Token, stored as a secret.
- RUNNER_SCOPE: Scope of the runner, set to org for organization-level runners.
- ORG_NAME: GitHub organization name where the runner will be registered.

You can find the full list of environment variables in [here](https://github.com/myoung34/docker-github-actions-runner)

## Github Token Scope

Creating GitHub personal access token (PAT) for using by self-hosted runner make sure the following scopes are selected:

- repo (all)
- admin:org (all) (mandatory for organization-wide runner)
- admin:enterprise (all) (mandatory for enterprise-wide runner)
- admin:public_key - read:public_key
- admin:repo_hook - read:repo_hook
- admin:org_hook
- notifications
- workflow

