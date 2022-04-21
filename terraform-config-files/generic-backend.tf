terraform {
  backend "s3" {
    bucket   = "tfstate_bucket"
    key      = "paretofrontier/_REPLACE_.tfstate"
    region   = "us-ashburn-1"
    endpoint = "https://id2wumpe9xu8.compat.objectstorage.us-ashburn-1.oraclecloud.com"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}