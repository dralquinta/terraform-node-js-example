# Sample with Terraform and forked process on nodejs

### sample tfvars file

```terraform
user_ocid = "ocid1.user.oc1..foobar"
fingerprint = "11:fo:bar:bar:foo70"
tenancy_ocid = "ocid1.tenancy.oc1..foobar"

memory = "2"
cpus = "1"

compartment_ocid = "ocid1.compartment.oc1..foobar"
subnet_ocid = "ocid1.subnet.oc1.sa-santiago-1.foobar"
region = "sa-santiago-1"
ad = "oDQF:SA-SANTIAGO-1-AD-1"
custom_image_ocid = "ocid1.image.oc1.sa-santiago-1.foobar"

ssh_public_key = "./keys/SSH/id_rsa.pub"
ssh_private_key = "./keys/SSH/id_rsa"
private_key_path = "./api_key.pem"

wait_time = 5

compartment_name = "DALQUINT_HUB"
network_compartment_name = "DALQUINT_HUB"
subnet_name = "dalquint_hub_pvt_subnet"
vcn_display_name = "DALQUINT_HUB_VCN"
```