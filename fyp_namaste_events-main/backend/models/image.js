const mongoose = require("mongoose");
const { vendorModel } = require("./vendor");

const imgSchema = new mongoose.Schema({
  fileName: { type: String, required: true },
  filePath: { type: String, required: true },
  srcFrom: { type: String, required: true },
});

const imageModel = mongoose.model("imageModel", imgSchema);

module.exports = { imageModel };
