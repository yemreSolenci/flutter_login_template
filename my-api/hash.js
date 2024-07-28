const bcrypt = require("bcrypt");

const password = "asdqwe"; // Hash'lemek istediğiniz şifre
const saltRounds = 10; // Hash için tuz (salt) sayısı

bcrypt.hash(password, saltRounds, (err, hash) => {
  if (err) {
    console.error(err);
  } else {
    console.log("Hash:", hash);
  }
});
