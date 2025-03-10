const express = require("express");
const router = express.Router();
const { vendorModel } = require("../models/vendor");
const { connectAdminDB } = require("../Config/DBconfig");
const encrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const upload = require("../Config/multerConfig");
const jwtExpiryMinute = 60;

const vendorData = [];
// POST API to add vendor signup details
router.post("/sign_up", async (req, res) => {
  const vdata = {
    vendorName: req.body.vendorName,
    email: req.body.email,
    phone: req.body.phone,
    password: req.body.password,
  };

  connectAdminDB.call();

  let duplicateEmail = await vendorModel.findOne({ email: vdata.email });
  if (duplicateEmail) {
    return res.status(400).json({
      status_code: 400,
      message: "Vendor already exists. Please login",
    });
  } else {
    try {
      const salt = await encrypt.genSalt(10);
      const passwordEncrypted = await encrypt.hash(vdata.password, salt);
      let newVendor = new vendorModel({
        vendorName: vdata.vendorName,
        email: vdata.email,
        phone: vdata.phone,
        password: passwordEncrypted,
      });

      await newVendor.save().then(() => {
        res.status(200).send({
          status_code: 200,
          message: "Vendor registered successfully",
          vendorDetails: vdata,
        });
      });
    } catch (err) {
      return res.status(400).json({ message: err.message });
    }
  }
});

// POST API to login vendor
router.post("/login", async (req, res) => {
  const vdata = {
    email: req.body.email,
    password: req.body.password,
  };

  connectAdminDB.call();

  let existEmail = await vendorModel.findOne({ email: vdata.email });
  if (!existEmail) {
    return res.status(400).json({
      status_code: 400,
      message: "Vendor doesn't exist. Please sign up",
    });
  } else {
    try {
      const correctPassword = await encrypt.compare(
        vdata.password,
        existEmail.password
      );
      if (!correctPassword) {
        return res
          .status(400)
          .json({ status_code: 400, message: "Incorrect email or password" });
      }

      const token = jwt.sign({ id: existEmail._id, role: "Admin" }, "SECRET");
      res.cookie("token", token, {
        httpOnly: true,
        secure: process.env.NODE_ENV !== "development",
        sameSite: "strict",
        maxAge: jwtExpiryMinute * 30,
      });

      return res.status(200).send({
        status_code: 200,
        message: "Vendor logged in successfully",
        role: "Admin",
      });
    } catch (err) {
      return res.status(400).json({ message: err.message });
    }
  }
});

router.post("/upload", upload.array("files"), async (req, res) => {
  console.log("file uploaded");
});

module.exports = router;
