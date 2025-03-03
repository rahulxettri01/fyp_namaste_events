const mongoose = require("mongoose");
const joi = require("joi");

const userSchema = new mongoose.Schema({
  userName: { type: String, required: true, unique: false },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  role: { type: String, default: "user" },
  // role: { type: String, default: "user", enum: ["user", "admin"] },
});

const user = mongoose.model("user", userSchema);

module.exports = { user };
