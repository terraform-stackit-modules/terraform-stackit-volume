variable "project_id" {
  description = "STACKIT project ID in which the volumes are created."
  type        = string
}

variable "region" {
  description = "The resource region. If not defined, the provider region is used."
  type        = string
  default     = null
}

variable "labels" {
  description = "Key-value string pairs applied to every volume (merged with per-volume labels)."
  type        = map(string)
  default     = {}
}

variable "volumes" {
  description = <<-EOT
    Map of block volumes to create, keyed by a STABLE identifier (used as the attachment key too,
    so `for_each` never runs over a known-after-apply value). Each value:
      - `availability_zone`     (required) : AZ of the volume, e.g. `eu01-1`.
      - `name`                             : the volume name.
      - `size`                             : size in GB. Either `size` OR `source` must be provided.
                                             Can only be resized to a LARGER value.
      - `source`                           : create the volume from a source instead of a bare size:
                                             `{ type = "image"|"volume"|"snapshot"|"backup", id = "<source-id>" }`.
      - `performance_class`                : BlockStorage performance class (service plan).
      - `description`                      : free-text description.
      - `labels`                           : per-volume labels (merged over `var.labels`).
      - `encryption_parameters`            : STACKIT-KMS encryption
                                             `{ kek_key_id, kek_key_version, kek_keyring_id, service_account, key_payload_base64? }`.
      - `attach_to_server_id`              : if set, also attach this volume to that existing server ID.
  EOT
  type = map(object({
    availability_zone = string
    name              = optional(string)
    size              = optional(number)
    source = optional(object({
      type = string
      id   = string
    }))
    performance_class = optional(string)
    description       = optional(string)
    labels            = optional(map(string), {})
    encryption_parameters = optional(object({
      kek_key_id         = string
      kek_key_version    = number
      kek_keyring_id     = string
      service_account    = string
      key_payload_base64 = optional(string)
    }))
    attach_to_server_id = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for v in values(var.volumes) :
      # `size` is required unless the source carries its own size (volume/snapshot/backup).
      # An `image` source still needs an explicit `size` (STACKIT API: "size is a
      # required option for no source or image source").
      v.size != null || contains(["volume", "snapshot", "backup"], try(v.source.type, ""))
    ])
    error_message = "Each volume must set `size` (required for no source and for an `image` source; a `volume`, `snapshot` or `backup` source may omit it)."
  }

  validation {
    condition = alltrue([
      for v in values(var.volumes) :
      v.source == null || contains(["image", "volume", "snapshot", "backup"], try(v.source.type, ""))
    ])
    error_message = "volumes[*].source.type must be one of: image, volume, snapshot, backup."
  }
}
