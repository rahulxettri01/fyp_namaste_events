const express = require("express");
const router = express.Router();
const { userModel } = require("../models/user");
const { vendorModel } = require("../models/vendor");
const { connectUserDB } = require("../Config/DBconfig");
const encrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

const jwtExpiryMinute = 60;

const userData = [];

// POST API to add signup details
router.post("/sign_up", async (req, res) => {
  console.log("back auth hit");

  const udata = {
    userName: req.body.userName,
    email: req.body.email,
    phone: req.body.phone,
    password: req.body.password,
    role: req.body.role,
  };

  userData.push(udata);
  console.log("Endpoint hit");
  connectUserDB.call();

  let duplicateEmail = await userModel.findOne({ email: udata.email });
  console.log("dub", duplicateEmail);
  if (duplicateEmail) {
    //    return res.status(400).send("User already exists. Please sign in");
    return res.status(400).json({
      status_code: 400,
      message: "User already exists. Please login",
    });
  } else {
    try {
      console.log("asd");
      const salt = await encrypt.genSalt(10);
      const passwordEncrypted = await encrypt.hash(udata.password, salt);
      console.log("suc", passwordEncrypted);
      console.log("rol", udata.role);
      if (udata.role == "Admin") {
        let newVendor = new vendorModel({
          vendorName: udata.userName,
          email: udata.email,
          phone: udata.phone,
          password: passwordEncrypted,
          role: udata.role,
          citizenshipFilePath: "",
          panFilePath: "",
        });
        await newVendor.save().then(() => {
          res.status(200).send({
            status_code: 200,
            message: "Vendor registered added successfully",
            userDetails: udata,
          });
        });
      } else {
        let newUser = new userModel({
          userName: udata.userName,
          email: udata.email,
          phone: udata.phone,
          password: passwordEncrypted,
          role: udata.role,
        });
        await newUser.save().then(() => {
          res.status(200).send({
            status_code: 200,
            message: "user registered added successfully",
            userDetails: udata,
          });
        });
      }
    } catch (err) {
      return res.status(400).json({ message: err.message });
    }
  }
});

router.post("/log_in", async (req, res) => {
  console.log("back auth hit");

  const udata = {
    email: req.body.email,
    password: req.body.password,
    role: req.body.role,
  };

  userData.push(udata);
  console.log("Endpoint hit");
  connectUserDB.call();

  let existEmail = await userModel.findOne({ email: udata.email });
  console.log("dub", existEmail);
  if (!existEmail) {
    //    return res.status(400).send("User already exists. Please sign in");
    return res.status(400).json({
      status_code: 400,
      message: "User doesn't exists. Please sign up",
    });
  } else {
    try {
      const correctPassword = await encrypt.compare(
        udata.password,
        existEmail.password
      );
      if (!correctPassword) {
        return res
          .status(400)
          .json({ status_code: 400, message: "Incorrect email or password" });
      }

      const token = jwt.sign(
        { id: existEmail._id, role: existEmail.role },
        "SECRET"
      );
      // setup cookies in frontend imp
      res.cookie("token", token, {
        httpOnly: true,
        secure: process.env.NODE_ENV !== "development",
        sameSite: "strict",
        role: existEmail.role,
        maxAge: jwtExpiryMinute * 30,
      });

      if (existEmail.role == "user") {
        return res.status(200).send({
          status_code: 200,
          message: "user logged in successfully",
          role: existEmail.role,
        });
      } else {
        return res.status(200).send({
          status_code: 200,
          message: "user logged in successfully",
          role: existEmail.role,
        });
      }
    } catch (err) {
      return res.status(400).json({ message: err.message });
    }
  }
});

module.exports = router;
