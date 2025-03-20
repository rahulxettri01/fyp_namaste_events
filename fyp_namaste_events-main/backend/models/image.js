const mongoose = require("mongoose");
const { vendorModel } = require("./vendor");

const docImgSchema = new mongoose.Schema({
  fileName: { type: String, required: true },
  filePath: { type: String, required: true },
  srcFrom: { type: String, required: true },
  type: { type: String, required: true },
});

const venueImgSchema = new mongoose.Schema({
  fileName: { type: String, required: true },
  filePath: { type: String, required: true },
  srcFrom: { type: String, required: true },
  type: { type: String, required: true },
});

const docImageModel = mongoose.model("docImageModel", docImgSchema);
const venueImageModel = mongoose.model("venueImageModel", venueImgSchema);

module.exports = { docImageModel, venueImageModel };
