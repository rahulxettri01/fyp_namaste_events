const express = require("express");
const mongoose = require("mongoose");
const app = express();
const PORT = 2000;
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
const multer = require("multer");

const venueData = [];

//connect to mongoose
mongoose.set("strictQuery", true);

// Multer configuration for file uploads
const upload = multer({ dest: "uploads/" });

//Routes
const venueAction = require("./routes/venueActions");
const userAuth = require("./routes/userAuthentication");
const VendorAuth = require("./routes/VendorAuthentication");

app.use("/api", venueAction);
app.use("/auth", userAuth);
app.use("/vendor", VendorAuth);

// File upload endpoint for vendors
// app.post(
//   "/vendor/upload",
//   upload.fields([{ name: "citizenship" }, { name: "pan" }]),
//   async (req, res) => {
//     try {
//       const { citizenship, pan } = req.files;
//       const vendorId = req.body.vendorId; // Assuming you send vendorId in the request body

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

app.listen(PORT, () => {
  console.log(`Connected to server at port ${PORT}`);
});
