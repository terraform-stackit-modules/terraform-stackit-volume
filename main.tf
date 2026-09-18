resource "stackit_network" "this" {
  project_id = var.project_id
  name       = "my-ephemeral-network"
}
