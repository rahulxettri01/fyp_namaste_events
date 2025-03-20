const { object } = require("joi");
const mongoose = require("mongoose");

const decoratorSchema = new mongoose.Schema({
  decoratorName: { type: String, required: true },
  address: { type: String, required: true, unique: true },
  price: { type: String, required: true },
  description: { type: String, required: true },
  accommodation: { type: Object, default: {} },
  status: { type: String, default: "avaiable" },
});

// todo : add ratings

const decoratorModel = mongoose.model("decoratorModel", decoratorSchema);

module.exports = { decoratorModel };
