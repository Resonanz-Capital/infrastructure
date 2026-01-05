# Contributing to Azure Infrastructure Project

Welcome! We're excited that you're interested in contributing to this Terraform/Terragrunt Azure infrastructure project. This document outlines the process for contributing and the standards we maintain.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Process](#development-process)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)
- [Pull Request Process](#pull-request-process)
- [Code of Conduct](#code-of-conduct)

## Getting Started

1. Fork the repository on GitHub
2. Clone your fork locally
3. Set up your development environment by installing the required tools:
   - Terraform >= 1.0
   - Terragrunt >= 0.32
   - Azure CLI
4. Create a new branch for your feature or bug fix

## Development Process

1. Always work on a feature branch, not main branches
2. Keep your branch up to date with the upstream main branch
3. Write clear, descriptive commit messages
4. Follow the Terraform style guide
5. Ensure all validation passes before submitting a pull request

## Coding Standards

### Terraform Standards

- Use snake_case for all variable and output names
- Use descriptive variable descriptions
- Use proper variable types and validation
- Keep modules focused and cohesive
- Use outputs to expose important information
- Document complex logic with comments

### Terragrunt Standards

- Use `find_in_parent_folders()` for including parent configurations
- Use `path_relative_to_include()` for unique state file keys
- Define dependencies explicitly using `dependencies` blocks
- Keep environment configurations clean and focused

### General Standards

- Use consistent indentation (2 spaces)
- Remove trailing whitespace
- Add appropriate comments for complex logic
- Follow the existing project structure and naming conventions

## Testing

Before submitting a pull request:

1. Run the validation script: `./validate.sh`
2. Run `terraform fmt` to format configuration files
3. Run `terraform validate` to check for syntax errors
4. Test your changes in a development environment
5. Ensure all Terragrunt configurations are valid

## Documentation

- Update the README.md if you change functionality
- Document new variables and outputs
- Update examples when adding new features
- Keep documentation clear and concise

## Pull Request Process

1. Ensure your changes pass all validation checks
2. Update the README.md with details of changes if applicable
3. Increase the version number in any examples if necessary
4. Submit a pull request with a clear title and description
5. Link any related issues in your pull request description
6. Be responsive to feedback and make requested changes

## Code of Conduct

This project follows a code of conduct that ensures a welcoming and inclusive environment for all contributors. Please be respectful and professional in all interactions.
