const express = require("express");
const mysql = require("mysql");
const bodyParser = require("body-parser");
const cors = require("cors");
const bcrypt = require("bcrypt");

const app = express();
app.use(cors());
app.use(bodyParser.json());

const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "root",
  database: "my_db",
});

db.connect((err) => {
  if (err) throw err;
  console.log("MySQL Connected...");
});

// Sağlık kontrolü endpoint'i
app.get("/health", (req, res) => {
  res.status(200).json({ message: "Server is healthy" });
});

// Kullanıcı güncelleme
app.put("/users/:id", (req, res) => {
  const userId = parseInt(req.params.id);
  const updatedUser = req.body;

  // Kullanıcıyı güncelleyen
  const sql = "UPDATE users SET ? WHERE id = ?";
  db.query(sql, [updatedUser, userId], (err, result) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ error: "Server error" });
    }

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    // Güncellenen kullanıcıyı döndür
    const updatedUserSql = "SELECT * FROM users WHERE id = ?";
    db.query(updatedUserSql, [userId], (err, updatedUserResult) => {
      if (err) {
        console.error(err);
        return res.status(500).json({ error: "Server error" });
      }

      res.status(200).json(updatedUserResult[0]);
    });
  });
});

// Cihaz güncelleme
app.put("/devices/:id", (req, res) => {
  const deviceId = parseInt(req.params.id);
  const updatedDevice = req.body;

  const deviceIndex = devices.findIndex((device) => device.id === deviceId);
  if (deviceIndex !== -1) {
    devices[deviceIndex] = { ...devices[deviceIndex], ...updatedDevice };
    res.status(200).json(devices[deviceIndex]);
  } else {
    res.status(404).json({ error: "Device not found" });
  }
});

// Kullanıcıları alma
app.get("/users", (req, res) => {
  const sql = "SELECT * FROM users";
  db.query(sql, (err, results) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ message: "Server error" });
    }
    res.json(results);
  });
});

// Get User ID by username
app.get("/getUserID", (req, res) => {
  const username = req.query.username;

  if (!username) {
    return res.status(400).json({ error: "Username is required" });
  }

  // Kullanıcıyı veritabanından bul
  const sql = "SELECT id FROM users WHERE username = ?";
  db.query(sql, [username], (err, result) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ message: "Server error" });
    }

    if (result.length > 0) {
      const user = result[0]; // Kullanıcıyı al
      res.json({ id: user.id }); // Kullanıcı id döndür
    } else {
      res.status(404).json({ message: "User not found!" });
    }
  });
});

// Cihazları alma
app.get("/devices", (req, res) => {
  const sql = "SELECT * FROM devices";
  db.query(sql, (err, results) => {
    if (err) {
      console.error("Error fetching devices: ", err);
      return res.status(500).json({ message: "Server error" });
    }
    res.json(results);
  });
});

// Kullanıcı kaydı
app.post("/register", (req, res) => {
  const {
    username,
    password,
    role = "user",
    first_Name,
    last_Name,
    city,
  } = req.body;

  // Kullanıcı adı kontrolü
  const checkUserSql = "SELECT * FROM users WHERE username = ?";
  db.query(checkUserSql, [username], (err, result) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ message: "Server error" });
    }

    if (result.length > 0) {
      // Kullanıcı adı zaten mevcut
      return res.status(400).json({ message: "Username already exists!" });
    }

    // Şifreyi hash'le
    bcrypt.hash(password, 10, (err, hash) => {
      if (err) {
        console.error(err);
        return res.status(500).json({ message: "Server error" });
      }

      // Yeni kullanıcıyı veritabanına ekle
      const sql =
        "INSERT INTO users (username, password, role, is_active, first_Name, last_Name, city) VALUES (?, ?, ?, b'0', ?, ?, ?)";
      db.query(
        sql,
        [username, hash, role, first_Name, last_Name, city],
        (err, result) => {
          if (err) {
            console.error(err);
            return res.status(500).json({ message: "Server error" });
          }
          res.status(201).json({ message: "User registered successfully!" });
        }
      );
    });
  });
});

// Kullanıcı rolünü alma
app.get("/getUserRole", (req, res) => {
  const username = req.query.username;

  // Kullanıcı adının boş olup olmadığını kontrol et
  if (!username) {
    return res.status(400).json({ message: "Username is required!" });
  }

  // Kullanıcıyı veritabanından bul
  const sql = "SELECT role FROM users WHERE username = ?";
  db.query(sql, [username], (err, result) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ message: "Server error" });
    }

    if (result.length > 0) {
      const user = result[0]; // Kullanıcıyı al
      res.json({ role: user.role }); // Kullanıcı rolünü döndür
    } else {
      res.status(404).json({ message: "User not found!" });
    }
  });
});

// Kullanıcı girişi
app.post("/login", (req, res) => {
  const { username, password } = req.body;

  // Kullanıcıyı veritabanından bul
  const sql = "SELECT * FROM users WHERE username = ?";
  db.query(sql, [username], (err, result) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ message: "Server error" });
    }

    if (result.length > 0) {
      const user = result[0]; // Kullanıcıyı al

      // Şifreyi doğrula
      bcrypt.compare(password, user.password, (err, isMatch) => {
        if (err) {
          console.error(err);
          return res.status(500).json({ message: "Server error" });
        }

        if (isMatch) {
          // Kullanıcının aktif olup olmadığını kontrol et
          if (user.is_active === 1) {
            res.json({ message: "Login successful!", role: user.role });
          } else {
            res.status(403).json({ message: "User is not active!" });
          }
        } else {
          res.status(401).json({ message: "Invalid credentials!" });
        }
      });
    } else {
      res.status(401).json({ message: "Invalid credentials!" });
    }
  });
});

app.get("/deviceData", (req, res) => {
  const deviceId = req.query.deviceId;

  if (!deviceId) {
    return res.status(400).json({ error: "Device ID is required" });
  }

  // Cihaz verilerini veritabanından al
  const sql = "SELECT * FROM device_data WHERE device_id = ?";
  db.query(sql, [deviceId], (err, results) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ message: "Server error" });
    }

    if (results.length > 0) {
      res.json(results); // Cihaz verilerini döndür
    } else {
      res.status(404).json({ message: "No data found for this device" });
    }
  });
});

// Kullanıcının cihazlarını alma
app.get("/users/:userId/devices", (req, res) => {
  const userId = parseInt(req.params.userId);
  const sql = `
    SELECT d.*
    FROM devices d
    INNER JOIN user_devices ud ON d.id = ud.device_id
    WHERE ud.user_id = ?
  `;
  db.query(sql, [userId], (err, results) => {
    if (err) {
      console.error("Error fetching user devices: ", err);
      return res.status(500).json({ message: "Server error" });
    }

    res.json(results);
  });
});

// Kullanıcıya cihaz atama
app.post("/users/:userId/devices", (req, res) => {
  const userId = parseInt(req.params.userId);
  const devices = req.body;

  // Önce mevcut cihazları kontrol et
  const checkSql = "SELECT device_id FROM user_devices WHERE user_id = ?";
  db.query(checkSql, [userId], (err, existingDevices) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ message: "Server error" });
    }

    // Yeni eklenecek cihazları bul
    const newDevices = devices.filter(
      (device) => !existingDevices.some((d) => d.device_id === device.id)
    );

    // Yeni cihazları ekle
    if (newDevices.length > 0) {
      const sql = "INSERT INTO user_devices (user_id, device_id) VALUES ?";
      const values = newDevices.map((device) => [userId, device.id]);

      db.query(sql, [values], (err, result) => {
        if (err) {
          console.error(err);
          return res.status(500).json({ message: "Server error" });
        }

        res.status(200).json({ message: "Devices successfully assigned" });
      });
    } else {
      res.status(200).json({ message: "Devices already assigned" });
    }
  });
});

// Kullanıcıdan cihaz silme
app.delete("/users/:userId/devices/:deviceId", (req, res) => {
  const userId = parseInt(req.params.userId);
  const deviceId = parseInt(req.params.deviceId);

  const sql = "DELETE FROM user_devices WHERE user_id = ? AND device_id = ?";
  db.query(sql, [userId, deviceId], (err, result) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ message: "Server error" });
    }

    if (result.affectedRows === 0) {
      return res
        .status(404)
        .json({ message: "Device not found or not assigned to user" });
    }

    res.status(200).json({ message: "Device successfully wiped" });
  });
});

// Sunucuyu başlat
app.listen(3000, () => {
  console.log("Server running on port 3000");
});
