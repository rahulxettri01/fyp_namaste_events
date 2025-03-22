const express = require("express");
const router = express.Router();
const { vendorModel } = require("../models/vendor");
const { connectInventoryDB } = require("../Config/DBconfig");
const encrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const { uploadVendor, uploadUser } = require("../Config/multerConfig");
const { diskStorage } = require("multer");
const VerifyJWT = require("../middleware/VerifyJWT");
const { Ruleset } = require("firebase-admin/security-rules");
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

  let duplicateEmail = null;
  connectInventoryDB(async () => {
    duplicateEmail = await vendorModel.findOne({ email: vdata.email });
  });

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

      connectInventoryDB(async () => {
        await newVendor.save().then(() => {
          res.status(200).send({
            status_code: 200,
            message: "Vendor registered successfully",
            vendorDetails: vdata,
          });
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

  let existEmail = null;

  connectInventoryDB(async () => {
    existEmail = await vendorModel.findOne({ email: vdata.email });
  });
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

// router.post("/upload", upload.array("files"), async (req, res) => {
//   console.log("file uploaded");
// });
router.post(
  "/vendorAuth/upload",
  VerifyJWT,
  uploadVendor.single("files"),
  async (req, res) => {
    // diskStorage.name;

    console.log("file ");
    res.status(200).send({
      status_code: 200,
      message: "File uploaded successfully",
    });
  }
);

// Route to update vendor status
// router.post("/update_vendor_status", VerifyJWT, async (req, res) => {
//   const { id, status } = req.body;

//   console.log("new hit");

//   connectInventoryDB(async () => {
//     try {
//       const vendor = await vendorModel.findByIdAndUpdate(
//         id,
//         { status: status },
//         { new: true }
//       );

//       if (!vendor) {
//         return res.status(404).json({
//           status_code: 404,
//           message: "Vendor not found",
//         });
//       }

//       res.status(200).send({
//         status_code: 200,
//         message: "Vendor status updated successfully",
//         vendor,
//       });
//     } catch (err) {
//       return res.status(400).json({ message: err.message });
//     }
//   });
// });

router.post("/update_vendor_status", (req, res) => {
  console.log("aaaa");
  const { id, status } = req.body;

  console.log("new hit");

  connectInventoryDB(async () => {
    try {
      const vendor = await vendorModel.findByIdAndUpdate(
        id,
        { status: status },
        { new: true }
      );

      if (!vendor) {
        return res.status(404).json({
          status_code: 404,
          message: "Vendor not found",
        });
      }

      res.status(200).send({
        status_code: 200,
        message: "Vendor status updated successfully",
        vendor,
      });
    } catch (err) {
      return res.status(400).json({ message: err.message });
    }
  });
});
module.exports = router;
