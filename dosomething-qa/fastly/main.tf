variable "graphql_name_dev" {}
variable "graphql_domain_dev" {}
variable "graphql_backend_dev" {}
variable "graphql_name_qa" {}
variable "graphql_domain_qa" {}
variable "graphql_backend_qa" {}

resource "fastly_service_v1" "dosomething-qa" {
  name = "Terraform: DoSomething (QA)"
  force_destroy = true

  domain {
    name = "${var.graphql_domain_dev}"
  }

  domain {
    name = "${var.graphql_domain_qa}"
  }

  condition {
    type = "REQUEST"
    name = "backend-graphql-dev"
    statement = "req.http.host == \"${var.graphql_domain_dev}\""
  }

  condition {
    type = "REQUEST"
    name = "backend-graphql-qa"
    statement = "req.http.host == \"${var.graphql_domain_qa}\""
  }

  condition {
    type = "REQUEST"
    name = "path-robots"
    statement = "req.url.basename == \"robots.txt\""
  }

  backend {
    address = "${var.graphql_backend_dev}"
    name = "${var.graphql_name_dev}"
    request_condition = "backend-graphql-dev"
    port = 443
  }
  
  backend {
    address = "${var.graphql_backend_qa}"
    name = "${var.graphql_name_qa}"
    request_condition = "backend-graphql-qa"
    port = 443
  }

  header {
    name = "Country Code"
    type = "request"
    action = "set"
    source = "geoip.country_code"
    destination = "http.X-Fastly-Country-Code"
  }

  header {
    name = "Country Code (Debug)"
    type = "response"
    action = "set"
    source = "geoip.country_code"
    destination = "http.X-Fastly-Country-Code"
  }

  response_object {
    name = "robots.txt deny"
    content = "${file("${path.module}/robots.txt")}"
    request_condition="path-robots"
  }
}

