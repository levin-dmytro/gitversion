provider "aws" {
  region  = "eu-central-1"
  profile = "default2"
}

resource "aws_iam_role" "codebuild_role" {
  name = "GitVersionCodeBuildTestRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "GitVersionCodeBuildTestPolicy"
  role = aws_iam_role.codebuild_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["logs:*", "s3:*"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_codebuild_project" "gitversion_test" {
  name          = "GitVersionFullCycleTest"
  description   = "Testing GitVersion across branches"
  build_timeout = "10"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/levin-dmytro/gitversion.git"
    git_clone_depth = 0
    buildspec       = "ci-cd-examples/aws-codebuild/buildspec.yml"
  }
}
