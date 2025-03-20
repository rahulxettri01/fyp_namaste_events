const express = require("express");
const mongoose = require("mongoose");
const dotenv = require("dotenv");
const multer = require("multer");
const app = express();
const PORT = 2000;

// Middleware to parse JSON and URL-encoded data
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Multer configuration for file uploads
const upload = multer({ dest: "uploads/" });

// Routes
const inventoryAction = require("./routes/inventoryActions");
const userAuth = require("./routes/userAuthentication");
const vendorAuth = require("./routes/VendorAuthentication");

const superAdminRoutes = require("./routes/admin");

app.use("/api", inventoryAction);
app.use("/auth", userAuth);
app.use("/vendor", vendorAuth);
app.use("/superadmin", superAdminRoutes);

// File upload endpoint for vendors
// app.post(
//   "/vendor/upload",
//   upload.fields([{ name: "citizenship" }, { name: "pan" }]),
//   async (req, res) => {
//     try {
//       const { citizenship, pan } = req.files;
//       const vendorId = req.body.vendorId;

//       const vendor = await vendorModel.findById(vendorId);
//       if (!vendor) {
//         return res.status(404).json({ message: "Vendor not found" });
//       }

//       vendor.citizenshipFilePath = citizenship[0].path;
//       vendor.panFilePath = pan[0].path;
//       await vendor.save();

//       res.status(200).json({ message: "Files uploaded successfully" });
//     } catch (err) {
//       res.status(500).json({ message: err.message });
//     }
//   }
// );

// const { superAdminModel } = require("./models/superadmin");
// const encrypt = require("bcrypt");
// const { connectSuperAdminDB } = require("./Config/DBconfig");

app.listen(PORT, async () => {
  console.log(`Connected to server at port ${PORT}`);
  // const salt = await encrypt.genSalt(10);
  // const passwordEncrypted = await encrypt.hash("superAdmin", salt);
  // const newAdmin = new superAdminModel({
  //   userName: "superAdmin",
  //   email: "superAdmin@gmail.com",
  //   password: passwordEncrypted,
  // });
  // connectSuperAdminDB.call();
  // await newAdmin.save().then(() => {
  //   console.log("SuperAdmin Created!!!");
  // });
});
