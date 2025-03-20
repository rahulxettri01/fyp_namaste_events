const mongoose = require("mongoose");

const vendorSchema = new mongoose.Schema({
  vendorName: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  phone: { type: String, required: true },
  password: { type: String, required: true },
  role: { type: String, default: "admin" },
  status: { type: String, default: "unverified" },
  citizenshipFilePath: { type: String },
  panFilePath: { type: String },
  category: { type: String, required: true },
});

const vendorModel = mongoose.model("vendorModels", vendorSchema);

module.exports = { vendorModel };
