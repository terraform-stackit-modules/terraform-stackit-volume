terraform {
  required_version = ">= 1.3"

  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = ">= 0.113.0"
    }
  }
}

# The kms.admin role assignment on the linked service account is a
# stackit_authorization_* resource: the provider must enable the iam experiment.
provider "stackit" {
  experiments = ["iam"]
}
