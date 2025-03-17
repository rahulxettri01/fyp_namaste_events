const express = require("express");
const router = express.Router();
const { userModel } = require("../models/user");
const { vendorModel } = require("../models/vendor");
const { connectUserDB, connectAdminDB } = require("../Config/DBconfig");
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
    category: req.body.vendorType ? req.body.vendorType : null,
  };

  userData.push(udata);
  console.log("Endpoint hit");
  let duplicateEmail = null;
  if (udata.role == "Admin") {
    connectAdminDB.call();
    duplicateEmail = await vendorModel.findOne({ email: udata.email });
  } else {
    connectUserDB.call();
    duplicateEmail = await userModel.findOne({ email: udata.email });
  }
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
        // connectAdminDB.call();
        let newVendor = new vendorModel({
          vendorName: udata.userName,
          email: udata.email,
          phone: udata.phone,
          password: passwordEncrypted,
          role: udata.role,
          citizenshipFilePath: "",
          panFilePath: "",
          category: udata.category,
        });
        console.log("modl", newVendor);

        await newVendor.save().then(() => {
          console.log("succeded");

          res.status(200).send({
            status_code: 200,
            message: "Vendor registered added successfully",
            userDetails: udata,
          });
        });
      } else {
        // connectUserDB.call();
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

  let existEmail = null;
  if (udata.role == "Admin") {
    connectAdminDB.call();
    existEmail = await vendorModel.findOne({ email: udata.email });
  } else {
    connectUserDB.call();
    existEmail = await userModel.findOne({ email: udata.email });
  }

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
        console.log("inc pas");
        return res
          .status(400)
          .json({ status_code: 400, message: "Incorrect email or password" });
      }

      // let tokenData = { id: existEmail._id, role: existEmail.role };
      // const token = await UserService.generateToken(
      //   tokenData,
      //   "serectKey",
      //   "1h"
      // );

      const token = jwt.sign(
        {
          id: existEmail._id,
          email: existEmail.email,
          role: existEmail.role,
          status: existEmail.status,
          category: existEmail.category,
        },
        "SECRET"
      );
      // setup cookies in frontend imp
      // res.json({ token, ...userModel._doc });

      // res.cookie("token", token, {
      //   httpOnly: true,
      //   secure: process.env.NODE_ENV !== "development",
      //   sameSite: "strict",
      //   role: existEmail.role,
      //   maxAge: jwtExpiryMinute * 30,
      // });

      if (existEmail.role == "User") {
        console.log("c pas u");
        return res.status(200).send({
          status_code: 200,
          message: "user logged in successfully",
          role: existEmail.role,
          token: token,
        });
      } else if (existEmail.role == "Admin") {
        console.log("c pas A");
        return res.status(200).send({
          status_code: 200,
          message: "Admin logged in successfully",
          role: existEmail.role,
          token: token,
        });
      }
      console.log("last mai");
    } catch (err) {
      console.log("err mai");
      console.log(err);
      return res.status(400).json({ message: err.message });
    }
  }
});

module.exports = router;
