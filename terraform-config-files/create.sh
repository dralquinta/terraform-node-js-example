#!/bin/sh

terraform init;
terraform validate;
terraform apply --auto-approve --var 'user_data'='#cloud-boothook\n#!/bin/bash\nwhoami > /tmp/root-output.txt\ndate >> /tmp/date.txt\ndocker run hello-world 2>/tmp/docker.log\ndate >> /tmp/date.txt';