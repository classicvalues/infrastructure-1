variable "northstar_pipeline" {}
variable "phoenix_pipeline" {}
variable "rogue_pipeline" {}
variable "papertrail_destination" {}
variable "papertrail_destination_fastly" {}

module "fastly-frontend" {
  source = "fastly-frontend"

  ashes_backend = "${module.ashes.backend}"

  phoenix_name    = "${module.phoenix.name}"
  phoenix_backend = "${module.phoenix.backend}"

  papertrail_destination = "${var.papertrail_destination_fastly}"
}

module "fastly-backend" {
  source = "fastly-backend"

  phoenix_preview_name    = "${module.phoenix_preview.name}"
  phoenix_preview_domain  = "${module.phoenix_preview.domain}"
  phoenix_preview_backend = "${module.phoenix_preview.backend}"

  northstar_name    = "${module.northstar.name}"
  northstar_domain  = "${module.northstar.domain}"
  northstar_backend = "${module.northstar.backend}"

  rogue_name    = "${module.rogue.name}"
  rogue_domain  = "${module.rogue.domain}"
  rogue_backend = "${module.rogue.backend}"

  papertrail_destination = "${var.papertrail_destination_fastly}"
}

module "graphql" {
  source = "../applications/graphql"

  environment = "production"
  name        = "dosomething-graphql"
  domain      = "graphql.dosomething.org"
  logger      = "${module.papertrail.arn}"
}

module "northstar" {
  source = "../applications/northstar"

  environment            = "production"
  name                   = "dosomething-northstar"
  domain                 = "identity.dosomething.org"
  pipeline               = "${var.northstar_pipeline}"
  papertrail_destination = "${var.papertrail_destination}"
}

module "phoenix" {
  source = "../applications/phoenix"

  environment            = "production"
  name                   = "dosomething-phoenix"
  domain                 = "www.dosomething.org"
  pipeline               = "${var.phoenix_pipeline}"
  papertrail_destination = "${var.papertrail_destination}"
}

module "phoenix_preview" {
  source = "../applications/phoenix"

  environment            = "production"
  name                   = "dosomething-phoenix-preview"
  domain                 = "preview.dosomething.org"
  web_size               = "Standard-1x"
  pipeline               = "${var.phoenix_pipeline}"
  papertrail_destination = "${var.papertrail_destination}"

  use_contentful_preview_api = true
}

module "rogue" {
  source = "../applications/rogue"

  environment            = "production"
  name                   = "dosomething-rogue"
  domain                 = "activity.dosomething.org"
  pipeline               = "${var.rogue_pipeline}"
  papertrail_destination = "${var.papertrail_destination}"
}

module "papertrail" {
  source = "../applications/papertrail"

  environment            = "production"
  name                   = "papertrail"
  papertrail_destination = "${var.papertrail_destination}"
}

module "ashes" {
  source = "ashes"
}
