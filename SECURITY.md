# Security Policy

## Supported Versions

This project is actively maintained and receives security updates for the latest version. We recommend always using the most recent release.

## Reporting a Vulnerability

If you discover a security vulnerability within this project, please follow these steps:

1. **Do not** create a public issue on GitHub
2. Send an email to the security team at security@project.org (replace with actual contact)
3. Include the following information in your report:
   - Description of the vulnerability
   - Steps to reproduce the issue
   - Potential impact of the vulnerability
   - Any possible mitigations you've identified

## Security Best Practices

### Azure Security

- Use managed identities instead of service principals when possible
- Enable Azure Security Center for all subscriptions
- Regularly rotate access keys and certificates
- Use Azure Key Vault for secrets management
- Implement network security groups to limit access
- Enable auditing and logging for all resources

### Terraform Security

- Never commit sensitive values to version control
- Use environment variables or secure vaults for secrets
- Regularly update provider versions
- Review plan output before applying changes
- Use separate state files for different environments
- Enable encryption for state files

### Terragrunt Security

- Use remote state with encryption
- Limit access to state files with appropriate IAM policies
- Use Terragrunt's `prevent_destroy` attribute for critical resources
- Implement proper dependency management to avoid cascading deletions

## Response Process

When a vulnerability is reported:

1. The security team will acknowledge receipt within 48 hours
2. We will investigate and validate the vulnerability
3. A timeline for resolution will be established
4. A security advisory will be published once the fix is available
5. Credit will be given to the reporter (unless they wish to remain anonymous)

## Additional Security Resources

- [Azure Security Documentation](https://docs.microsoft.com/en-us/azure/security/)
- [Terraform Security Documentation](https://www.terraform.io/docs/enterprise/private/module-registry/security.html)
- [Terragrunt Security Documentation](https://terragrunt.gruntwork.io/docs/features/security/)
