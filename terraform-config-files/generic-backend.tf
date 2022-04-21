terraform {
  backend "s3" {
    bucket   = "tfstate_bucket"
    key      = "Diego/_REPLACE_.tfstate"
    region   = "re-region-1"
    endpoint = "https://TENANCY_ID.compat.objectstorage.re-region-1.oraclecloud.com"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}