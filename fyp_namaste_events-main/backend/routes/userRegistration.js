const express = require("express");
const router = express.Router();
const { userModel } = require("../models/user");
const { connectUserDB } = require("../Config/DBconfig");
const encrypt = require("bcrypt");
const userData = [];

// POST API to add venue
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
    return res.status(400).send("User already exists. Please sign in");
  } else {
    try {
      console.log("asd");
      const salt = await encrypt.genSalt(10);
      const passwordEncrypted = await encrypt.hash(udata.password, salt);
      console.log("suc", passwordEncrypted);
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
          venue: udata,
        });
      });
    } catch (err) {
      return res.status(400).json({ message: err.message });
    }
  }
});

module.exports = router;
