const express = require("express");
const router = express.Router();
const { superAdminModel } = require("../models/superadmin");
const {
  connectSuperAdminDB,
  connectInventoryDB,
} = require("../Config/DBconfig");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const { vendorModel } = require("../models/vendor");

const jwtExpiryMinute = 60;

// require("dotenv").config();

// POST API for super admin login
router.post("/log_in", async (req, res) => {
  console.log("super admin hit");
  const { uEmail, password } = req.body;

  try {
    let superAdmin = null;

    await connectSuperAdminDB(async () => {
      superAdmin = await superAdminModel.find();
      // todo : find by email
    });
    console.log("admin det", superAdmin);

    await console.log("admin det", superAdmin);
    if (!superAdmin) {
      return res
        .status(400)
        .json({ message: "Super Admin doesn't exist. Please sign up." });
    }
    const isMatch = await bcrypt.compare(password, superAdmin[0].password);
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
    res.status(500).json({ message: err.message });
  }
});

router.get("/get_vendors", async (req, res) => {
  console.log("naya");
  let data = null;
  await connectInventoryDB(async () => {
    data = await vendorModel.find({ status: "unverified" });
  });
  console.log("all", data);

  return res.status(200).send({
    status_code: 200,
    message: "All unverified vendors retrived successfully",
    data: data,
  });
});

// router.get("get_vendors", async (req, res) => {
//   console.log("get vend");

//   let data = null;
//   connectSuperAdminDB(async () => {
//     data = vendorModel.find({ status: "unverified" });
//   });
//   console.log("all", data);

//   return res.status(200).send({
//     status_code: 200,
//     message: "All unverified vendors retrived successfully",
//     data: data,
//   });
// });

// Endpoint to get vendors by status
router.get("/vendors/:status", async (req, res) => {
  const status = req.params.status;

  try {
    const vendors = await vendorModel.find({ status: status });
    res.status(200).json({ success: true, data: vendors });
  } catch (error) {
    res
      .status(500)
      .json({ success: false, message: "Server error", error: error.message });
  }
});

router.post("/update_vendor", async (req, res) => {
  console.log(req.body);
});

module.exports = router;
