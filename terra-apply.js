// LIBS

const crypto = require("crypto");
// for reading files
const fs = require("fs");
const util = require("util");

// CHECK ARGS

const args = process.argv.slice(2);
const instance_name = args[0]
const cpus = args[1] != undefined ? args[1] : 8
const memory = args[2] != undefined ? args[2] : 64

create();

  async function create() {
    if(instance_name == undefined) {
      console.log('You must indicate a instance name');
      return;
    }

    // PREPARE TF FILE

    const file_name = 'terraform-config-files/generic-instance.tf';
    var fs = require('fs')
    fs.readFile(file_name, 'utf8', function (err,data) {
      if (err) {
        return console.log(err);
      }
      var result = data.replace(/_REPLACE_/g, instance_name);

      fs.writeFile('instance.tf', result, 'utf8', function (err) {
         if (err) return console.log(err);
      });
    });

    // ENCODE USER_DATA
    
    // docker service error: (Cannot connect to the Docker daemon)
    let user_data_decoded = "#cloud-boothook\n#!/bin/bash\nwhoami > /tmp/root-output.txt\ndate >> /tmp/date.txt\ndocker run hello-world 2>/tmp/docker.log\ndate >> /tmp/date.txt"
    
    // crashes the instance, can't connect via ssh: (same with and without 'sudo')
    // let user_data_decoded = "#cloud-boothook\n#!/bin/bash\nwhoami > root-output.txt\nsudo usermod -a -G docker $USER\nsudo systemctl enable docker.service\nsudo systemctl start docker.service\nsudo chmod 666 /var/run/docker.sock\ndocker run hello-world 2>docker.log"
    
    // crashes the instance, can't connect via ssh: (same with and without 'sudo')
    // let user_data_decoded = "#cloud-boothook\n#!/bin/bash\newhoami > root-output.txt\n~/InfraDockerBot/configDocker.sh 2>docker.log\ndocker run hello-world 2>docker.log"
    
    let user_data_encoded = Buffer.from(user_data_decoded).toString("base64");

    // TERRAFORM APPLY

    //const terraform_cmd = 'terraform apply -auto-approve -var "name='+instance_name+'" -var "cpus='+cpus+'" -var "memory='+memory+'" -var "user_data='+user_data_encoded+'" -target=oci_core_instance.'+instance_name;
    const terraform_cmd = 'terraform init; terraform apply --var-file=vars.tfvars --auto-approve;'
    console.log(`terraform_cmd: ${terraform_cmd}`);

    const { exec } = require('child_process');
    exec(terraform_cmd, (err, stdout, stderr) => {
      if (err) {
        //some err occurred
        console.error(err)
      } else {
       // the *entire* stdout and stderr (buffered)
       console.log(`stdout: ${stdout}`);
       console.log(`stderr: ${stderr}`);
      }
    });
  }
