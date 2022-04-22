// LIBS

const {
    encrypt,
    decryptEntity,
    encryptTradeconfig,
} = require("./encryption");
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
      console.log('[0/6] You must indicate a instance name');
      return;
    }


    // PREPARE TF FILES
    console.log('[1/6] Generating instance.tf file..');
    const instance_file_name = 'terraform-config-files/generic-instance.tf';
    var fs = require('fs')
    fs.readFile(instance_file_name, 'utf8', function (err,data) {
      if (err) {
        return console.log(err);
      }
      var result = data.replace(/_REPLACE_/g, instance_name);

      fs.writeFile('instance.tf', result, 'utf8', function (err) {
         if (err) return console.log(err);
      });
    });

    console.log('[2/6] Generating output.tf file..');
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

    console.log('[3/6] Generating backend.tf file..');
    const backend_file_name = 'terraform-config-files/generic-backend.tf';
    var fs = require('fs')
    fs.readFile(backend_file_name, 'utf8', function (err,data) {
      if (err) {
        return console.log(err);
      }
      var result = data.replace(/_REPLACE_/g, instance_name);

      fs.writeFile('backend.tf', result, 'utf8', function (err) {
         if (err) return console.log(err);
      });
    });

    console.log('[3b/6] Generating trade_config-original.txt file..');
    const trade_config_file_name = 'terraform-config-files/generic_trade_config.txt';
    var fs = require('fs')
    fs.readFile(trade_config_file_name, 'utf8', function (err,data) {
      if (err) {
        return console.log(err);
      }
      var result = data.replace(/_REPLACE_/g, instance_name);

      fs.writeFile('trade_config_original.txt', result, 'utf8', function (err) {
         if (err) return console.log(err);
      });
    });


    // READ TRADE_CONFIG
    console.log('[4/6] Reading TRADE_CONFIG file..');
    let data = new Map();;
    //data.uuid = uuidv4();
    // this only rewrites the UUID value from the file
    let readFile = util.promisify(fs.readFile);
    let writeFile = util.promisify(fs.writeFile);
    let file = await readFile("generic_trade_config.txt");
    file = JSON.parse(file.toString());


    // ENCRYPT TRADE_CONFIG
    console.log('[5/6] Encrypting TRADE_CONFIG file..');
    let key = "39YaYUYaPtmafn5k81lSXpd3hcHvx6Fq"; // TODO: get from strapi.config.ciph; // custom key
    let iv = crypto.randomBytes(16); // initialization vector
    let secret = "paretofrontier"; // TODO: get from data.secret;
    if (secret != "" && secret != undefined && secret != null) {
        let ciphered_secret = encrypt(secret, key, iv);
        data["iv"] = ciphered_secret.iv;
        data["secret"] = ciphered_secret.encryptedData;
        // encrypt the file
        file = encryptTradeconfig(JSON.stringify(file), key, iv);

        data["encrypted_tradeconfig"] = file;
        await writeFile("trade_config.txt", file);
    }


    // TODO: data for terraform variables
    let bot_name = instance_name;
    let exchange = 'ftx';
    let paper_trading = 'yes';
    let no_mail = 1;
    let bot_version = 'latest';
    let encrypted_tradeconfig = data["encrypted_tradeconfig"];
    let encrypted_iv = data["iv"];

    // TERRAFORM APPLY
    //const terraform_cmd = 'terraform apply -auto-approve -var "bot_name='+bot_name+'" -var "exchange='+exchange+'" -var "paper_trading='+paper_trading+'" -var "no_mail='+no_mail+'" -var "bot_version='+bot_version+'"  -var "trade_config='+trade_config+'"  -var "iv='+iv+'" -target=oci_core_instance.'+instance_name;0
    const terraform_cmd = 'terraform init -reconfigure; terraform apply --var-file=vars.tfvars --auto-approve -var "bot_name='+bot_name+'" -var "exchange='+exchange+'" -var "paper_trading='+paper_trading+'" -var "no_mail='+no_mail+'" -var "bot_version='+bot_version+'" -var "trade_config='+encrypted_tradeconfig+'" -var "iv='+encrypted_iv+'";'
    console.log(`[6/6] Running Terraform: ${terraform_cmd}`);

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