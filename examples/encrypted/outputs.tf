output "volume_ids" {
  description = "The IDs of the encrypted volumes created by the example."
  value       = module.encrypted_volume.volume_ids
}

output "volumes_encrypted" {
  description = "Whether the volumes created by the example are encrypted."
  value       = module.encrypted_volume.volumes_encrypted
}
