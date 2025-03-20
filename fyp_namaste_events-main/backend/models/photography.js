const { object } = require("joi");
const mongoose = require("mongoose");

const photographySchema = new mongoose.Schema({
  photographyName: { type: String, required: true },
  address: { type: String, required: true, unique: true },
  price: { type: String, required: true },
  description: { type: String, required: true },
  accommodation: { type: Object, default: {} },
  status: { type: String, default: "avaiable" },
});

// todo : add ratings

const photographyModel = mongoose.model("photographyModel", photographySchema);

module.exports = { photographyModel };
