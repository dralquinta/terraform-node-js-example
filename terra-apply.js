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


    // PREPARE TF FILES

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

    const output_file_name = 'terraform-config-files/generic-output.tf';
    var fs = require('fs')
    fs.readFile(output_file_name, 'utf8', function (err,data) {
      if (err) {
        return console.log(err);
      }
      var result = data.replace(/_REPLACE_/g, instance_name);

      fs.writeFile('output.tf', result, 'utf8', function (err) {
         if (err) return console.log(err);
      });
    });


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
