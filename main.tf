resource "stackit_volume" "this" {
  for_each = var.volumes

  project_id        = var.project_id
  region            = var.region
  availability_zone = each.value.availability_zone
  name              = each.value.name
  size              = each.value.size
  performance_class = each.value.performance_class
  description       = each.value.description
  labels            = merge(var.labels, each.value.labels)

  # source is a nested single attribute → assign with = { ... } (never dynamic {})
  source = each.value.source

  # encryption_parameters is a nested single attribute → = { ... }
  encryption_parameters = each.value.encryption_parameters
}

# Optional: attach a created volume to an existing server. Keyed by the SAME stable
# key as the volume (known at plan time), so for_each never runs over a
# known-after-apply value such as the created volume_id.
resource "stackit_server_volume_attach" "this" {
  for_each = {
    for k, v in var.volumes : k => v.attach_to_server_id
    if v.attach_to_server_id != null
  }

  project_id = var.project_id
  region     = var.region
  server_id  = each.value
  volume_id  = stackit_volume.this[each.key].volume_id
}
