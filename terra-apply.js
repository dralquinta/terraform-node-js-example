// LIBS

const express = require("express"); // npm install express
const bodyParser = require('body-parser'); // npm install body-parser
const app = express();
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

const {
    encrypt,
    decryptEntity,
    encryptTradeconfig,
} = require("./encryption");
const crypto = require("crypto");
// for reading files
const fs = require("fs");
const util = require("util");

// API
app.listen(8000, () => {
 console.log("Server initialized on port 8000");
});

let bot_args = {
 nickname: '',
 bot_name: '',
 exchange:'',
 paper_trading: '',
 no_mail:'',
 bot_version: '',
 encrypted_tradeconfig: '',
 encrypted_iv:'',
};

app.post('/create_and_run', async function (req, res) {
  try {
    validation_response = validate(req.body, req.headers)
    if (validation_response == undefined) {
      console.log("--------------------------")
      create(req.body);
      console.log("--------------------------")
      return res.status(200).json({ date: new Date(), message: 'Instance '+req.body.nickname+' is being creating..'});
    } else {
      console.log(validation_response)
      return res.status(500).json(validation_response);
    }

  } catch(error) {
    console.log(error);
    return res.status(500).json({ message: error.message});
  }
});

app.get('/health', function (req, res) {
    let secret = "UGFyZXRvVGVycmFmb3JtISE=";
    if(req.headers["secret"] == undefined) {
      return res.status(500).json({ date: new Date(), error_code: "missing_secret", message: "Secret value is required."});
    } else if (req.headers["secret"] != secret) {
      return res.status(500).json({ date: new Date(), error_code: "bad_secret", message: "Secret value is invalid."});
    } else {
      return res.status(200).json({ date: new Date(), message: '[OCI] Terraform Instance Creator. Make a POST to /create_and_run'});
    }
});

app.get('/find/:bot_name', function (req, res) {
  var bot_name = req.params.bot_name;
  resp = find_instance_by_name(req.headers, bot_name);
  if(!resp.hasOwnProperty("error_code"))
    return res.status(200).json(resp);
  else if(resp['error_code'] == 'invalid_bot_name')
    return res.status(404).json(resp);
  else
    return res.status(500).json(resp);

});

app.delete('/terminate/:nickname', function (req, res) {
  var nickname = req.params.nickname;
  resp = terminateInstance(req.headers, nickname);
  return res.status(200).json(resp);
});


// ---------------------------------------------------------

  function validate(body, headers) {

    let secret = "UGFyZXRvVGVycmFmb3JtISE=";
    if(headers["secret"] == undefined) {
      return { date: new Date(), error_code: "missing_secret", message: "Secret value is required."};
    } else if (headers["secret"] != secret) {
      return { date: new Date(), error_code: "bad_secret", message: "Secret value is invalid."};
    }

    resp = undefined;
    respMsg = "";
    const {
       nickname,
       bot_name,
       exchange,
       paper_trading,
       no_mail,
       bot_version,
       encrypted_tradeconfig,
       encrypted_iv
    } = body;

    if(nickname == undefined) {
      respMsg += 'You must indicate a nickname. ';
    } 
    if(bot_name == undefined) {
      respMsg += 'You must indicate a bot_name. ';
    } 
    if(exchange == undefined) {
      respMsg += 'You must indicate a exchange. ';
    } 
    if(paper_trading == undefined) {
      respMsg += 'You must indicate paper_trading param. ';
    } 
    if(no_mail == undefined) {
      respMsg += 'You must indicate no_mail param. ';
    } 
    if(bot_version == undefined) {
      respMsg += 'You must indicate a bot_version. ';
    } 
    if(encrypted_tradeconfig == undefined) {
      respMsg += 'You must indicate a encrypted_tradeconfig. ';
    } 
    if(encrypted_iv == undefined) {
      respMsg += 'You must indicate a encrypted_iv. ';
    }

    if(respMsg == "") {  // if args are ok, check if an instance with same name exists
      const execSync = require('child_process').execSync;
      instlist = 'oci compute instance list --compartment-id ocid1.tenancy.oc1..aaaaaaaaurx6kiejqos56erltmqvj4hfwz6x3aoa673krc2l5pbvjlh7wnka';
      const result = execSync(instlist, {encoding: 'utf8', timeout: 50000}); // run syncronic
      let json = JSON.parse(result);
      if(json != undefined) {
        for (const instance of json["data"]) {
          if(instance["display-name"] == nickname && instance["lifecycle-state"] == "RUNNING") {
            msg = 'An instance called '+nickname+' was created at '+instance["time-created"]
            resp = { date: new Date(), error_code: "bot_name_exists", message: msg}
          }
        }
      }
    } else {
      resp = { date: new Date(), error_code: "missing_params", message: respMsg}
    }

    return resp;
  }


  function create(body) {

    const {
       nickname,
       bot_name,
       exchange,
       paper_trading,
       no_mail,
       bot_version,
       encrypted_tradeconfig,
       encrypted_iv
    } = body;

    // REMOVE PREVIOUS TF FILES
    console.log('### Removing previous instance.tf, backend.tf & output.tf files..');
    var fs = require('fs')
    try {
      fs.unlinkSync('./instance.tf')
      fs.unlinkSync('./output.tf')
      fs.unlinkSync('./backend.tf')
      //files removed
    } catch(err) {
      console.error(err)
    }


    // PREPARE NEW TF FILES
    console.log('### Generating terraform files..');
    var fs = require('fs');

    const instance_file_name = 'terraform-config-files/generic-instance.tf';
    var instance_file = fs.readFileSync(instance_file_name, 'utf8')
    var edited = instance_file.replace(/_REPLACE_/g, bot_name);
    fs.writeFileSync('instance.tf', edited, 'utf8');

    const output_file_name = 'terraform-config-files/generic-output.tf';
    var output_file = fs.readFileSync(output_file_name, 'utf8')
    var edited = output_file.replace(/_REPLACE_/g, bot_name);
    fs.writeFileSync('output.tf', edited, 'utf8');

    const backend_file_name = 'terraform-config-files/generic-backend.tf';
    var backend_file = fs.readFileSync(backend_file_name, 'utf8')
    var edited = backend_file.replace(/_REPLACE_/g, bot_name);
    fs.writeFileSync('backend.tf', edited, 'utf8');


    // TERRAFORM APPLY
    const execSync = require('child_process').execSync;

    const terraform_cmd = 'terraform init -reconfigure; terraform apply --var-file=vars.tfvars --auto-approve -var "nickname='+nickname+'" -var "bot_name='+bot_name+'" -var "exchange='+exchange+'" -var "paper_trading='+paper_trading+'" -var "no_mail='+no_mail+'" -var "bot_version='+bot_version+'" -var "trade_config='+encrypted_tradeconfig+'" -var "iv='+encrypted_iv+'";'
    console.log('### Running Terraform: Instance '+bot_name+' is being creating..');

    const { exec } = require('child_process');
    exec(terraform_cmd, (err, stdout, stderr) => {
      if (err) {
        //some err occurred
        console.error(err)
      } else {
       // the *entire* stdout and stderr (buffered)
        const output = execSync("terraform output", {encoding: 'utf8', timeout: 5000}); // get output - run syncronic
        console.log(`stdout: ${output}`);
      }
    });

  }

  function find_instance_by_name(headers, bot_name) {

    let secret = "UGFyZXRvVGVycmFmb3JtISE=";
    if(headers["secret"] == undefined) {
      return { date: new Date(), error_code: "missing_secret", message: "Secret value is required."};
    } else if (headers["secret"] != secret) {
      return { date: new Date(), error_code: "bad_secret", message: "Secret value is invalid."};
    } else if(bot_name == undefined || bot_name == '') {
      return { date: new Date(), error_code: "missing_bot_name", message: "Instance name value is required."};
    }

    const execSync = require('child_process').execSync;
    instlist = 'oci compute instance list --compartment-id ocid1.tenancy.oc1..aaaaaaaaurx6kiejqos56erltmqvj4hfwz6x3aoa673krc2l5pbvjlh7wnka';
    const result = execSync(instlist, {encoding: 'utf8', timeout: 10000}); // run syncronic
    let json = JSON.parse(result);
    if(json != undefined) {
      for (const instance of json["data"]) {
        if(instance["display-name"] == bot_name && instance["lifecycle-state"] == "RUNNING") {
          return {
            'display_name': instance["display-name"],
            'instance_id': instance["id"],
            'private_ip': instance["private_ip"],
            'shape': instance["shape"],
            'state': instance["lifecycle-state"],
            'time_created': instance["defined-tags"]["Oracle-Tags"]["CreatedOn"],
            'user_created': instance["defined-tags"]["Oracle-Tags"]["CreatedBy"]
          }
        }
      }

      return {
          'message': 'No instance with name '+bot_name,
          'date': new Date(),
          'error_code': 'invalid_bot_name'
      }

    } else {
      return {
          'message': 'Failed to get instance list on OCI',
          'date': new Date(),
          'error_code': 'failed_to_get_instance_list'
      }
    }

  }

  function terminateInstance(headers, bot_name) {

    let secret = "UGFyZXRvVGVycmFmb3JtISE=";
    if(headers["secret"] == undefined) {
      return { date: new Date(), error_code: "missing_secret", message: "Secret value is required."};
    } else if (headers["secret"] != secret) {
      return { date: new Date(), error_code: "bad_secret", message: "Secret value is invalid."};
    } else if(bot_name == undefined || bot_name == '') {
      return { date: new Date(), error_code: "missing_bot_name", message: "Instance name value is required."};
    }

    instance = find_instance_by_name(headers, bot_name);

    console.log("Terminating instance "+bot_name);
    terminate_cmd = 'oci compute instance terminate --force --instance-id '+instance['instance_id'];
    const { exec } = require('child_process');
    exec(terminate_cmd, (err, stdout, stderr) => {
      if (err) {
        //some err occurred
        console.error(err)
      }
    });

    console.log('Removing bucket paretofrontier/'+bot_name+'.tfstate');
    remove_bucket_cmd = 'oci os object delete --force --bucket-name tfstate_bucket --object-name paretofrontier/'+bot_name+'.tfstate';
    exec(remove_bucket_cmd, (err, stdout, stderr) => {
      if (err) {
        //some err occurred
        console.error(err)
      }
    });

    return { date: new Date(), message: 'Terminating instance '+bot_name+' - '+instance['instance_id'] };

  }

  /*acceso al repo
  generar dockerfile y docker compose
  
  construccion de landing zone
  construccion de kubernetes
  mover el ms a kubernetes
  config api gateway
  dns zone*/