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
const vendorRoutes = require("./routes/vendor"); // Import the new vendor routes
const imageRoutes = require("./routes/images"); // Import the new image routes
const superAdminRoutes = require("./routes/admin");

app.use("/api", inventoryAction);
app.use("/auth", userAuth);
app.use("/vendor", vendorAuth);
app.use("/superadmin", superAdminRoutes);
app.use("/images", imageRoutes); // Use the new image routes

// app.use("/api", vendorRoutes); // Use the new vendor routes

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
