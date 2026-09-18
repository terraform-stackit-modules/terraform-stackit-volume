#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module.
#
# This example is self-contained and requires only `project_id`: it creates two
# block volumes — one sized from scratch and one from an image source.
#####################################################################################

module "volume" {
  source = "../.."

  project_id = var.project_id

  volumes = {
    data = {
      availability_zone = var.availability_zone
      name              = "example-data-volume"
      size              = 10
      description       = "Example data volume created from scratch"
    }
    from_image = {
      availability_zone = var.availability_zone
      name              = "example-image-volume"
      size              = 10
      source = {
        type = "image"
        id   = var.image_id
      }
    }
  }

  labels = {
    managed_by = "terraform"
    example    = "basic"
  }
}
