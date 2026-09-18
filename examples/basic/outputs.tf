output "volume_ids" {
  description = "Map of volume key to created volume ID."
  value       = module.volume.volume_ids
}

output "volume_names" {
  description = "Map of volume key to volume name."
  value       = module.volume.volume_names
}
