## provider.tf

### Responsibility

The `provider.tf` file configures the behavior of the AWS Provider.

It defines:

- AWS Region
- Default tags
- Other provider-specific settings

### Key Points

- The provider is installed during `terraform init` based on `versions.tf`.
- `provider.tf` only configures the provider.
- Credentials are **not** stored in this file.
- The AWS Provider automatically discovers credentials through the AWS SDK credential provider chain.

### Default Tags

Every resource created by this Terraform configuration automatically receives:

- Project = n8n
- ManagedBy = Terraform

This ensures consistent resource tagging without repeating the same tags for every resource.


## terraform.tfvars

### Responsibility

The `terraform.tfvars` file provides values for the variables declared in `variables.tf`.

It contains environment-specific configuration without modifying the infrastructure code.

### Current Values

| Variable | Value |
|----------|-------|
| aws_region | ap-south-1 |

### Design Decision

The project uses `terraform.tfvars` for local development.

In production, sensitive values should be supplied through secure mechanisms such as environment variables, GitHub Actions secrets, or Terraform Cloud workspace variables instead of committing them to version control.

## variables.tf

### Responsibility

The `variables.tf` file defines the input variables required by the Terraform configuration.

Variables make the infrastructure reusable by separating the infrastructure definition from environment-specific values.

### Current Variables

| Variable | Type | Description |
|----------|------|-------------|
| aws_region | string | AWS region where resources will be created. |

### Design Decision

Only variables required by the current infrastructure are declared.

Additional variables will be introduced as new resources are added, avoiding unnecessary complexity.

For cost optimization, this project uses a single NAT Gateway. In a production environment requiring high availability, each Availability Zone would have its own NAT Gateway and Private Route Table to eliminate cross-AZ dependencies."