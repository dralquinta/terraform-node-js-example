# Sample with Terraform and forked process on nodejs

### sample tfvars file

```oci credentials for terraform 
user_ocid = "ocid1.user.oc1..foobar"
fingerprint = "11:fo:bar:bar:foo70"
tenancy_ocid = "ocid1.tenancy.oc1..foobar"

name = "test"
memory = "2"
cpus = "1"

compartment_ocid = "ocid1.compartment.oc1..foobar"
subnet_ocid = "ocid1.subnet.oc1.sa-santiago-1.foobar"
region = "sa-santiago-1"
ad = "oDQF:SA-SANTIAGO-1-AD-1"
custom_image_ocid = "ocid1.image.oc1.sa-santiago-1.foobar"
shape = "VM.Standard.E3.Flex"

ssh_public_key = "./keys/SSH/id_rsa.pub"
ssh_private_key = "./keys/SSH/id_rsa"
private_key_path = "./api_key.pem"

wait_time = 5
shape = "VM.Standard.E4.Flex"
```

```local environment variables
export TF_VAR_GH_USER="<value>"
export TF_VAR_GH_DCKR_TKN="<value>"
export TF_VAR_DOCKER_PASS="<value>"
export TF_VAR_DOCKER_USER="<value>"
```