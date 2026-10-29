#####################################################################################
# "encrypted" example — requires only `project_id`.
#
# Creates the full KMS encryption chain for a volume, using the published
# `terraform-stackit-kms` and `terraform-stackit-service-account` modules
# end-to-end:
#   1. a keyring and a symmetric key-encryption-key (KEK) via the kms module,
#   2. a service account that the storage backend uses to access the key,
#   3. a volume encrypted against that KEK.
#####################################################################################

# Keyring + key-encryption-key via the published kms module.
# A freshly created key is at version 1.
module "kms" {
  source  = "terraform-stackit-modules/kms/stackit"
  version = ">= 1.0.0"

  project_id          = var.project_id
  keyring_name        = "example-encrypted-volumes"
  keyring_description = "Keyring for the encrypted volume example"

  keys = {
    volume_kek = {
      display_name = "example-volume-kek"
      algorithm    = "aes_256_gcm"
      purpose      = "symmetric_encrypt_decrypt"
      protection   = "software"
    }
  }
}

# The service account linked to the key, via the published service-account
# module. The storage backend uses it to access the key-encryption-key
# inside STACKIT-KMS.
module "service_account" {
  source  = "terraform-stackit-modules/service-account/stackit"
  version = ">= 1.0.0"

  project_id = var.project_id
  name       = "encrypted-vol-sa" # max 20 characters
}

# The linked service account MUST hold the kms.admin role on the project:
# the storage backend impersonates it to wrap/unwrap the volume's data key
# (permission kms.key.version.decrypt, which kms.reader does NOT contain).
# Without this assignment the volume creation fails with
# "STACKIT_KMS_PLUGIN: KMS Error: Access Forbidden".
#
# NOTE (Terratest/prerequisite): creating this role assignment requires the
# CALLER (the CI service account) to hold the "IAM Member Admin" role on the
# project (permission iam.member.add). Grant it out-of-band via the STACKIT
# Portal (IAM & management > Access) or the stackit CLI — a service account
# cannot grant itself this permission.
module "authorization" {
  source  = "terraform-stackit-modules/authorization/stackit"
  version = ">= 1.0.0"

  project_role_assignments = {
    kms = {
      resource_id = var.project_id
      role        = "kms.admin"
      subject     = module.service_account.service_account_email
    }
  }
}

module "encrypted_volume" {
  source = "../.."

  project_id = var.project_id

  volumes = {
    encrypted = {
      availability_zone = "eu01-1"
      name              = "example-encrypted-volume"
      size              = 10

      # The volume's data key is encrypted against this KEK inside STACKIT-KMS.
      # NOTE: these parameters never leave the backend again (not returned by
      # imports or the data source).
      encryption_parameters = {
        kek_key_id      = module.kms.key_ids["volume_kek"]
        kek_key_version = 1
        kek_keyring_id  = module.kms.keyring_id
        service_account = module.service_account.service_account_email
      }
    }
  }

  # The volume must not be created before the service account can actually
  # use the key.
  depends_on = [module.authorization]
}
