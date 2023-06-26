terraform {
  required_version = ">= 1.0.0"

  required_providers {
    ec = {
      source  = "elastic/ec"
      version = "0.7.0"
    }
  }
}

provider "ec" {
}

locals {
  bundle_file_path = "/path/to/bundle.zip"
  plugin_file_path = "/path/to/bundle.zip"
}

data "ec_stack" "latest" {
  version_regex = "latest"
  region        = "us-east-1"
}

resource "ec_deployment_extension" "sudachi_dict_bundle" {
  name           = "try-vector-search-sudachi-dict"
  description    = "いつでも消して良い"
  version        = "*"
  extension_type = "bundle"

  file_path = local.bundle_file_path
  file_hash = filebase64sha256(local.bundle_file_path)
}

resource "ec_deployment_extension" "sudachi_plugin" {
  name           = "try-vector-search-sudachi-plugin"
  description    = "いつでも消して良い"
  version        = data.ec_stack.latest.version
  extension_type = "plugin"

  file_path = local.plugin_file_path
  file_hash = filebase64sha256(local.plugin_file_path)
}

resource "ec_deployment" "try-vector-search" {
  name = "try-vector-search"

  region                 = "us-east-1"
  version                = data.ec_stack.latest.version
  deployment_template_id = "aws-io-optimized-v2"

  elasticsearch = {
    config = {
      plugins = ["analysis-icu", "analysis-kuromoji"]
    },
    hot = {
      autoscaling = {}
    },
    extension = [{
      name    = ec_deployment_extension.sudachi_dict_bundle.name
      type    = "bundle"
      version = data.ec_stack.latest.version
      url     = ec_deployment_extension.sudachi_dict_bundle.url
    }]
  }

  kibana = {}

  enterprise_search = {}

  integrations_server = {}
}