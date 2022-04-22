
const crypto = require('crypto');

module.exports = {
  encrypt(text, key, iv) {
    let cipher = crypto.createCipheriv('aes-256-cbc', Buffer.from(key), iv);
    let encrypted = cipher.update(text);
    encrypted = Buffer.concat([encrypted, cipher.final()]);
    return { iv: iv.toString('hex'), encryptedData: encrypted.toString('hex') };
  },
  decrypt(text, key, ivv) {
    let iv = Buffer.from(ivv, 'hex');
    let encryptedText = Buffer.from(text, 'hex');
    let decipher = crypto.createDecipheriv('aes-256-cbc', Buffer.from(key), iv);
    let decrypted = decipher.update(encryptedText);
    decrypted = Buffer.concat([decrypted, decipher.final()]);
    return decrypted.toString();
  },
  decryptEntity(entity) {
    let key = strapi.config.ciph; // custom key
    let iv = entity.iv;
  
    if (entity.secret != '' && entity.secret != undefined) {
      let deciphered_secret = module.exports.decrypt(entity.secret, key, iv);
      entity['secret'] = deciphered_secret;
    }
    // if (entity.tradeconfig != '' && entity.tradeconfig != undefined) {
    //   let deciphered_config = module.exports.decrypt(entity.tradeconfig, key, iv);
    //   entity['tradeconfig'] = deciphered_config;
    // }
  
    return entity;
  },
  decryptSubaccount(entity) {
    let key = strapi.config.ciph; // custom key
    let iv = entity.iv;
  
    if (entity.sec != '' && entity.sec != undefined) {
      let deciphered_secret = module.exports.decrypt(entity.sec, key, iv);
      entity['sec'] = deciphered_secret;
    }
    
    return entity;
  },
  encryptTradeconfig(text, key, iv) {
    let cipher = crypto.createCipheriv('aes-256-cbc', Buffer.from(key), iv);
    let encrypted = cipher.update(text);
    encrypted = Buffer.concat([encrypted, cipher.final()]);
    return encrypted.toString('hex');
  },
  decryptTradeconfig(entity, file) {
    let key = strapi.config.ciph; // custom key
    let iv = entity.iv;
    let file_decrypted = file;
  
    let deciphered_secret = module.exports.decrypt(file, key, iv);
    file_decrypted = deciphered_secret;
  
    return file_decrypted;
  },
}

