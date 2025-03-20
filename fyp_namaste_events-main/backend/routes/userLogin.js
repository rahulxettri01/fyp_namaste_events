const express = require("express");
const router = express.Router();
const { userModel } = require("../models/user");
const { connectUserDB } = require("../Config/DBconfig");
const encrypt = require("bcrypt");
const VerifyJWT = require("../middleware/VerifyJET");
const userData = [];

// User login route (POST)
router.post("/login", async (req, res) => {
  const { error } = authUser(req.body);
  const { email, password } = req.body;
  if (error) {
    return res.status(400).send(error.details[0].message);
  } else {
    try {
      connectDB.call();

      let isValid = await user.findOne({ email: email });
      if (!isValid) {
        return res
          .status(400)

          .json({ message: "Incorrect email or password." });
      }
    } catch (err) {
      return res.status(400).json({ message: err.message });
    }
  }
});
module.exports = router;
