## Microservices with Terraform on nodejs

> Microservice to create an instance on OCI and run a BOT inside it. 

First, a nodejs endpoint validates all required params.<br />
Then, using OCI CLI, validates that there is no previous Instance on OCI with the same name.<br />
If all is ok, the process prepares somee terraform files from a generic ones.<br />
In the end, te process makes a call to terraform in order to create the instance.<br />
With a null-resource, terraform wait 5 seconds to get the instance with docker, node and git running correctly.<br />
Then, with a remote-exec command, terraform runs some scripts on the new Instance.<br />
Docker image is pulled and the Bot starts to work. Also Zabbix server is launched too.<br />

_Requirements_:

- ✨Nodejs ✨
- ✨Terraform ✨
- ✨OCI CLI ✨

_Libs_:
- npm install body-parser
- npm install express

---------------------------------------------------------------------------------------------------------------------------------------
## To run locally, you must have these 3 config files:

### sample ./vars.tfvars file
> [Terraform tfvars](https://www.terraform.io/language/values/variables#variable-definitions-tfvars-files)

```OCI Credentials for Terraform 
user_ocid    = "ocid1.user.oc1..example"
fingerprint  = "15:f1:b9:..example"
tenancy_ocid = "ocid1.tenancy.oc1..example"
tenancy_name = "paretofrontier"

compartment_ocid    = "ocid1.compartment.oc1..example" // Pareto Frontier Compartment
private_vcn_name    = "test_vcn"
private_subnet_name = "private_subnet" // Private SUBNET for Instances
region              = "us-ashburn-1"
ad                  = "ssii:US-ASHBURN-AD-1"

# customized-ubuntu-image-with-docker-git-node-python
custom_image_name = "customized-ubuntu-image-with-docker-git-node-python"
shape             = "VM.Standard.E4.Flex"

# keys
ssh_public_key   = "./keys/id_rsa.pub"
ssh_private_key  = "./keys/id_rsa"
private_key_path = "./keys/03-26-00-03.pem"

wait_time = 5  # in seconds, to run the remote-exec command list
memory    = "64"
cpus      = "8"

DOCKER_USER = "dh_user"
DOCKER_PASS = "dh_pass"
```
---------------------------------------------------------------------------------------------------------------------------------------

### sample ~/.oci/config file - OCI CLI Credentials
> [OCI CLI Configuration](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm#InstallingCLI__linux_and_unix)

```OCI CLI Credentials
To run OCI CLI, you need a file on ~/.oci/config with that content: 

[DEFAULT]
user=ocid1.user.oc1..example
fingerprint=15:f1:b9:..example
key_file=../keys/03-26-00-03.pem
tenancy=ocid1.tenancy.oc1..example
region=us-ashburn-1

```
---------------------------------------------------------------------------------------------------------------------------------------

### sample ~/.aws/credentials file - OCI S3 Bucket
> [OCI Buckets](https://cloud.oracle.com/object-storage/buckets?region=us-ashburn-1)

```OCI S3 Bucket
To able terraform to connect to OCI S3 Bucket, you need a file on ~/.aws/credentials with that content. 
We found that data on Bucket section inside OCI:

[default]
aws_access_key_id=df5da..example
aws_secret_access_key=5xdtP..example

```
---------------------------------------------------------------------------------------------------------------------------------------
## MS Endpoints specification

### GET /bot-instance/health

> GET to [https://la3kxh774jj5vxycdkvorvbd3m.apigateway.us-ashburn-1.oci.customer-oci.com/bot-instance/health](https://la3kxh774jj5vxycdkvorvbd3m.apigateway.us-ashburn-1.oci.customer-oci.com/bot-instance/health)

```
status: 200
response: {
    "date": "2022-05-03T12:13:24.097Z",
    "message": "[OCI] Terraform Instance Creator. Make a POST to /create_and_run"
}
```
---------------------------------------------------------------------------------------------------------------------------------------

### POST /bot-instance/create_and_run

> POST to [https://la3kxh774jj5vxycdkvorvbd3m.apigateway.us-ashburn-1.oci.customer-oci.com/bot-instance/create_and_run](https://la3kxh774jj5vxycdkvorvbd3m.apigateway.us-ashburn-1.oci.customer-oci.com/bot-instance/create_and_run)

```
Body: {
    "bot_name":"test-js-131",
    "exchange":"ftx",
    "paper_trading":"yes",
    "no_mail":"1",
    "bot_version":"latest",
    "encrypted_tradeconfig":"f88d20d7ceef0682848db9aa..example..42f127bfd713f4c00bdab4",
    "encrypted_iv":"2942296766e..example..7a1f59483"
}
```
- All of them are **required**
- Must have a "**secret**" value in the headers

```
status: 200
response: {
    "date": "2022-05-09T20:31:55.060Z",
    "message": "Instance test-js-135 created successfully!",
    "response": {
        "display_name": "test-js-135",
        "instance_id": "ocid1.instance.oc1.iad.anuwcljsjfdsdxicz7vk5szffuxhcabg7hjovhuo55ewx3yxhsbupfm4nhmq",
        "private_ip": "10.0.0.218",
        "shape": "VM.Standard.E3.Flex",
        "state": "RUNNING",
        "time_created": "2022-05-09 20:31:10.949 +0000 UTC"
    }
}
```
```
status: 500
response: {
    "date": "2022-05-09T20:32:45.060Z",
    "message": "Instance test-js-135 has invalid status. Check it!",
    "response": {
        "display_name": "test-js-135",
        "instance_id": "ocid1.instance.oc1.iad.anuwcljsjfdsdxicz7vk5szffuxhcabg7hjovhuo55ewx3yxhsbupfm4nhmq",
        "private_ip": "10.0.0.218",
        "shape": "VM.Standard.E3.Flex",
        "state": "TERMINATED",
        "time_created": "2022-05-09 20:32:15.949 +0000 UTC"
    }
}
```
```
status: 500
response: {
  date: 2022-05-03T12:06:50.636Z,
  error_code: 'instance_name_exists',
  message: 'An instance called test-js-131 was created at 2022-05-03T03:00:00.394000+00:00'
}
```
```
status: 500
response: {
  date: 2022-05-03T12:08:56.866Z,
  error_code: 'missing_params',
  message: 'You must indicate a bot_name. You must indicate a exchange. You must indicate paper_trading param. You must indicate no_mail param. You must indicate a bot_version. You must indicate a encrypted_tradeconfig. You must indicate a encrypted_iv. '
}
```
```
status: 500
response: {
  date: 2022-05-03T14:39:04.825Z,
  error_code: 'missing_secret',
  message: 'Secret value is required.'
}
```
```
status: 500
response: {
  date: 2022-05-03T14:39:04.825Z,
  error_code: 'bad_secret',
  message: 'Secret value is invalid.'
}
```
---------------------------------------------------------------------------------------------------------------------------------------

### DELETE /bot-instance/terminate/{instance_id}

> DELETE to [https://la3kxh774jj5vxycdkvorvbd3m.apigateway.us-ashburn-1.oci.customer-oci.com/bot-instance/terminate/{instance_id}](https://la3kxh774jj5vxycdkvorvbd3m.apigateway.us-ashburn-1.oci.customer-oci.com/bot-instance/terminate/{instance_id})

- instance_id param is **required**
- Must have a "**secret**" value in the headers

```
status: 200
response: {
    "date": "2022-05-10T00:06:32.916Z",
    "message": "Terminating instance ocid1.instance.oc1.iad.anuwcljsjfdsdxicx344ygvpvmgxup5kqxmkzw4wzofwnldg4nr5lk5mmn6a"
}
```