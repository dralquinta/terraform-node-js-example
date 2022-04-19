#!/bin/sh

terraform init;
terraform validate;
terraform destroy --auto-approve --var 'user_data'='#cloud-boothook\n#!/bin/bash\nwhoami > /home/ubuntu/root-output.txt\ndocker run hello-world 2>/home/ubuntu/docker.log';