const express = require("express");
const router = express.Router();
const { superAdminModel } = require("../models/superadmin");
const { connectSuperAdminDB } = require("../Config/DBconfig");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

const jwtExpiryMinute = 60;

require("dotenv").config();

// POST API for super admin login
router.post("/log_in", async (req, res) => {
  const { email, password } = req.body;

  try {
    connectSuperAdminDB.call();
    const superAdmin = await superAdminModel.findOne({ email });
    console.log("admin det", superAdmin);

    if (!superAdmin) {
      return res
        .status(400)
        .json({ message: "Super Admin doesn't exist. Please sign up." });
    }

    const isMatch = await bcrypt.compare(password, superAdmin.password);

    if (!isMatch) {
      return res.status(400).json({ message: "Incorrect email or password." });
    }

    const token = jwt.sign(
      { id: superAdmin._id, email: superAdmin.email, role: superAdmin.role },
      "SECRET",
      { expiresIn: jwtExpiryMinute * 30 }
    );

    return res.status(200).send({
      status_code: 200,
      message: "Super Admin logged in successfully.",
      token: token,
    });
  } catch (err) {
    res.status(500).json({ message: "llll" });
  }
});

router.get("get_vendors", async (req, res) => {
  return res.send({ message: "dus" });
});
module.exports = router;
