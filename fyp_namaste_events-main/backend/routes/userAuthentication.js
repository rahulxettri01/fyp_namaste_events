const express = require("express");
const router = express.Router();
const { userModel } = require("../models/user");
const {
  vendorModel,
  photographyModel,
  venueModel,
  decoratorModel,
} = require("../models/vendor");
const {
  connectUserDB,
  connectInventoryDB,
  connectSuperAdminDB,
} = require("../Config/DBconfig");
const encrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

const jwtExpiryMinute = 60;

const userData = [];

require("dotenv").config();

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
  console.log("Endpoint dhit");
  let duplicateEmail = null;
  if (udata.role == "Admin") {
    await connectInventoryDB(async () => {
      duplicateEmail = await vendorModel.findOne({ email: udata.email });
    });
  } else if (udata.role == "super Admin") {
    await connectSuperAdminDB(async () => {
      duplicateEmail = await userModel.findOne({ email: udata.email });
    });
  } else {
    await connectUserDB(async () => {
      duplicateEmail = await userModel.findOne({ email: udata.email });
    });
  }
  console.log("dub", duplicateEmail);
  if (duplicateEmail) {
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
        let newVendor;
        let vendorType;
        newVendor = new vendorModel({
          vendorName: udata.userName,
          email: udata.email,
          phone: udata.phone,
          password: passwordEncrypted,
          role: udata.role,
          citizenshipFilePath: "",
          panFilePath: "",
          category: udata.category,
        });
        // if (udata.category == "Venue") {
        //   vendorType = new venueModel({
        //     venueName: udata.userName,
        //     address: udata.address,
        //     price: udata.price,
        //     description: udata.description,
        //     accommodation: udata.accommodation,
        //     status: udata.status,
        //   });
        // } else if (udata.category == "Photography") {
        //   vendorType = new photographyModel({
        //     photographyName: udata.photographyName,
        //     address: udata.address,
        //     price: udata.price,
        //     description: udata.description,
        //     accommodation: udata.accommodation,
        //     status: udata.status,
        //   });
        // } else {
        //   vendorType = new decoratorModel({
        //     decoratorName: udata.decoratorName,
        //     address: udata.address,
        //     price: udata.price,
        //     description: udata.description,
        //     accommodation: udata.accommodation,
        //     status: udata.status,
        //   });
        // }
        console.log("modl", newVendor);

        await connectInventoryDB(async () => {
          // await vendorType.save();
          await newVendor.save().then(() => {
            console.log("succeded");

            res.status(200).send({
              status_code: 200,
              message: "Vendor registered successfully",
              userDetails: udata,
            });
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
        connectUserDB(async () => {
          await newUser.save().then(() => {
            res.status(200).send({
              status_code: 200,
              message: "User registered successfully",
              userDetails: udata,
            });
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
  console.log("Endpoint hit", udata);

  let existEmail = null;
  if (udata.role == "Admin") {
    await connectInventoryDB(async () => {
      existEmail = await vendorModel.findOne({ email: udata.email });
    });
    console.log("new", existEmail);
  } else if (udata.role == "super admin") {
    await connectSuperAdminDB(async () => {
      existEmail = await userModel.findOne({ email: udata.email });
    });
  } else {
    await connectUserDB(async () => {
      existEmail = await userModel.findOne({ email: udata.email });
    });
  }

  console.log("dubeee", existEmail);
  if (!existEmail) {
    return res.status(400).json({
      status_code: 400,
      message: "User doesn't exist. Please sign up",
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

      if (existEmail.role == "User") {
        console.log("c pas u");
        return res.status(200).send({
          status_code: 200,
          message: "User logged in successfully",
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
      } else if (existEmail.role == "super admin") {
        console.log("c pas SA");
        return res.status(200).send({
          status_code: 200,
          message: "Super Admin logged in successfully",
          role: existEmail.role,
          token: token,
        });
      }
    } catch (err) {
      console.log("err mai");
      console.log(err);
      return res.status(400).json({ message: err.message });
    }
  }
});

module.exports = router;
