const express = require("express");
const router = express.Router();
const { OTP } = require("../models/otp");
const { sendOTPEmail } = require("../utils/emailUtils");
const { connectUserDB } = require("../Config/DBconfig");

// Generate and send OTP
router.post("/generate", async (req, res) => {
  const { email, userName } = req.body;

  try {
    await connectUserDB(async () => {
      // Generate 6-digit OTP
      const otp = Math.floor(100000 + Math.random() * 900000).toString();

      // Create or update OTP record
      await OTP.findOneAndUpdate(
        { email },
        {
          otp,
          createdAt: new Date(),
          attempts: 0,
        },
        { upsert: true, new: true }
      );

      // Send email
      await sendOTPEmail(email, otp, userName);

      res.status(200).json({
        success: true,
        message: "OTP sent successfully",
      });
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to send OTP",
    });
  }
});

// Verify OTP
router.post("/verify", async (req, res) => {
  const { email, otp } = req.body;

  try {
    await connectUserDB(async () => {
      const otpRecord = await OTP.findOne({ email });

      if (!otpRecord) {
        return res.status(400).json({
          success: false,
          message: "OTP expired or not found",
        });
      }

      if (otpRecord.otp !== otp) {
        // Increment failed attempts
        await OTP.updateOne({ email }, { $inc: { attempts: 1 } });

        return res.status(400).json({
          success: false,
          message: "Invalid OTP",
        });
      }

      // OTP verified successfully
      await OTP.deleteOne({ email });

      res.status(200).json({
        success: true,
        message: "OTP verified successfully",
      });
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "OTP verification failed",
    });
  }
});

module.exports = router;
