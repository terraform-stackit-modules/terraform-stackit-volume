output "volume_ids" {
  description = "Map of volume key to created volume ID."
  value       = { for k, v in stackit_volume.this : k => v.volume_id }
}

output "volume_names" {
  description = "Map of volume key to volume name."
  value       = { for k, v in stackit_volume.this : k => v.name }
}

output "volumes_encrypted" {
  description = "Map of volume key to whether the volume is encrypted."
  value       = { for k, v in stackit_volume.this : k => v.encrypted }
}

output "attached_server_ids" {
  description = "Map of volume key to the server ID it is attached to (only volumes with attach_to_server_id)."
  value       = { for k, a in stackit_server_volume_attach.this : k => a.server_id }
}
