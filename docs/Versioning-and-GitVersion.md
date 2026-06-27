# Versioning Strategy & GitVersion

## Purpose

This document explains the semantic versioning strategy, branching model logic, and the automated version calculation mechanisms used across the Digital Foundation projects.

## Audience

Developers, DevOps engineers, Release Managers, and QA engineers who need to understand how version numbers are calculated and how CI/CD pipelines generate version tags.

## Current State

The platform utilizes **GitVersion v6.x** to automatically compute Semantic Versions (SemVer) dynamically based on our GitFlow branching model and commit history. This approach completely eliminates the need for manual version bumping in code or properties files.

## Key Details

### 1. The Branching Model (GitFlow)

Our version calculation is deeply integrated with the GitFlow branching model. GitVersion understands the semantics of different branch types and applies appropriate version bumps and pre-release tags automatically:

- **`main`**: The production-ready state. Commits on `main` represent stable releases. By default, merging a `release` or `feature` branch into `main` calculates the next stable version (e.g., `1.1.1` or `1.2.0`).
- **`develop`**: The integration branch for the next release. Versions here include an `alpha` pre-release tag indicating the upcoming version (e.g., `1.2.0-alpha.2`).
- **`feature/*`**: Feature branches inherit the version of `develop` but append the feature name as a pre-release tag to isolate the build (e.g., `1.2.0-my-feature.1`).
- **`release/*`**: Stabilization branches preparing for production. Versions here use a `beta` or `rc` pre-release tag (e.g., `1.2.0-beta.1`).
- **`hotfix/*`**: Emergency fixes directly targeting `main`. They bump the patch version (e.g., `1.1.2-beta.1`).

### 2. Conventional Commits

While GitFlow structure alone dictates the general flow of versions, **Conventional Commits** can be used to explicitly force specific version increments within the branch:

- `fix:` / `bugfix:` → Forces a **Patch** increment (e.g., `1.1.0` → `1.1.1`).
- `feat:` / `feature:` → Forces a **Minor** increment (e.g., `1.1.1` → `1.2.0`).
- `BREAKING CHANGE:` → Forces a **Major** increment (e.g., `1.2.0` → `2.0.0`).

*Note: In GitVersion v6, if you merge a feature branch into `develop` without any `feat:` prefix, the system still gracefully increments the minor version because merging into `develop` inherently signals a continuous minor version progression.*

### 3. CI/CD Integrations

GitVersion v6 is platform-agnostic. We support its execution across various CI/CD toolchains. A sandbox repository with full working examples is available at [levin-dmytro/gitversion](https://github.com/levin-dmytro/gitversion).

#### AWS CodeBuild
In standard CodeBuild environments (`aws/codebuild/standard:7.0`), .NET 6.0 is pre-installed. The cleanest integration is via the .NET Global Tool:
```yaml
phases:
  install:
    commands:
      - dotnet tool install --global GitVersion.Tool --version 6.0.2
      - export PATH="$PATH:/root/.dotnet/tools"
  pre_build:
    commands:
      - IMAGE_TAG=$(dotnet-gitversion /output json /showvariable SemVer)
```

#### GitHub Actions
Use the official GitTools Action:
```yaml
- uses: actions/checkout@v4
  with:
    fetch-depth: 0 # Required for GitVersion

- uses: gittools/actions/gitversion/setup@v3.0.0
  with:
    versionSpec: '6.0.0'

- id: gitversion
  uses: gittools/actions/gitversion/execute@v3.0.0
  with:
    useConfigFile: true
```

#### GitLab CI
Use the official Docker image to calculate the version:
```yaml
determine_version:
  image:
    name: gittools/gitversion:6.0.2-debian.11-6.0
    entrypoint: ['']
  script:
    - VERSION=$(/tools/dotnet-gitversion /output json /showvariable SemVer)
```

#### Bitbucket Pipelines
Use the official Docker image and ensure full clone depth:
```yaml
clone:
  depth: full # Required for GitVersion
pipelines:
  default:
    - step:
        image: gittools/gitversion:6.0.2-debian.11-6.0
        script:
          - VERSION=$(/tools/dotnet-gitversion /output json /showvariable SemVer)
```
