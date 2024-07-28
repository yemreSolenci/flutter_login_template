const bcrypt = require("bcrypt");

const hashedPassword =
  "$2b$10$AdGapP7S9PRCWo.X6eNm9etDHvaLfMYkfQc9BjhdXQgSHgikwyzbK"; // Örnek hash
const passwordToCheck = "qweasd"; // Kontrol etmek istediğiniz şifre

bcrypt.compare(passwordToCheck, hashedPassword, (err, isMatch) => {
  if (err) {
    console.error(err);
  } else {
    console.log("Doğrulama sonucu:", isMatch); // true veya false döner
  }
});
