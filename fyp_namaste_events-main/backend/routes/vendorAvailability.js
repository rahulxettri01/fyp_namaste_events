const express = require("express");
const router = express.Router();
const { AvailabilityModel } = require("../models/Availability");
const VerifyJWT = require("../middleware/VerifyJWT");
const { connectInventoryDB } = require("../Config/DBconfig");
const { vendorModel } = require("../models/vendor");

// Helper function to validate time format (HH:mm)
const isValidTimeFormat = (time) => {
  const timeRegex = /^([01]?[0-9]|2[0-3]):[0-5][0-9]$/;
  return timeRegex.test(time);
};

// Create availability slot
router.post("/create-slot", VerifyJWT, async (req, res) => {
  try {
    console.log(req.user);

    const vendorEmail = req.user["email"];
    const { date, startDate, endDate, category } = req.body;

    // Validate required fields
    if (!vendorEmail || !date || !startDate || !endDate || !category) {
      return res.status(400).json({
        success: false,
        message: "All fields are required",
      });
    }

    // Verify vendor exists and check category
    let vendor;
    await connectInventoryDB(async () => {
      vendor = await vendorModel.find({ email: vendorEmail });
    });
    // vendorModel.findOne({ email: vendorEmail });
    console.log("ven", vendor[0].category);

    if (!vendor) {
      return res.status(404).json({
        success: false,
        message: "Vendor not found",
      });
    }

    console.log("db ven cat", vendor[0].category);
    console.log("cat", category);

    // Verify vendor category matches
    if (vendor[0].category !== category) {
      return res.status(403).json({
        success: false,
        message:
          "Vendor can only create availability for their registered category",
      });
    }

    // Validate date format and range
    const startDateObj = new Date(startDate);
    const endDateObj = new Date(endDate);
    const now = new Date();

    if (isNaN(startDateObj.getTime()) || isNaN(endDateObj.getTime())) {
      return res.status(400).json({
        success: false,
        message: "Invalid date format. Use YYYY/MM/DD",
      });
    }

    if (startDateObj < now) {
      return res.status(400).json({
        success: false,
        message: "Cannot create availability for past dates",
      });
    }

    const monthDiff = (endDateObj - startDateObj) / (1000 * 60 * 60 * 24 * 30);
    if (monthDiff > 1) {
      return res.status(400).json({
        success: false,
        message: "Date range cannot exceed 1 month",
      });
    }

    // Check for conflicting slots
    // const conflictingSlot = await vendorAvailabilityModel.findOne({
    //   vendorEmail,
    //   category,
    //   $or: [
    //     {
    //       startDate: { $lte: endDate },
    //       endDate: { $gte: startDate },
    //     },
    //   ],
    // });

    // if (conflictingSlot) {
    //   return res.status(400).json({
    //     success: false,
    //     message: "A slot already exists for this time period",
    //   });
    // }

    // Create new availability slot
    const newSlot = new AvailabilityModel({
      vendorEmail,
      category,
      startDate,
      endDate,
      isAvailable: true,
    });

    connectInventoryDB(async () => {
      await newSlot.save();
    });
    res.status(201).json({
      success: true,
      message: "Availability slot created successfully",
      data: newSlot,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: `Error creating availability slot: ${error.message}`,
    });
  }
});

// Get vendor availability
router.get("/available", async (req, res) => {
  try {
    const { vendorEmail } = req.body;
    let availability;
    await connectInventoryDB(async () => {
      availability = await AvailabilityModel.find({
        vendorEmail,
      }).sort({ date: 1 });
    });
    res.json({ success: true, data: availability });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: `Error fetching availability: ${error.message}`,
    });
  }
});

// Update vendor availability
router.post("/vendor-availability/update", VerifyJWT, async (req, res) => {
  try {
    const { vendorId, date, isAvailable } = req.body;

    // Find existing availability or create new one
    let availability = await vendorAvailabilityModel.findOne({
      vendorId,
      date: new Date(date),
    });

    if (availability) {
      availability.isAvailable = isAvailable;
      availability.updatedAt = new Date();
      await availability.save();
    } else {
      availability = new vendorAvailabilityModel({
        vendorId,
        date: new Date(date),
        isAvailable,
      });
      await availability.save();
    }

    res.json({
      success: true,
      message: "Availability updated successfully",
      data: availability,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: `Error updating availability: ${error.message}`,
    });
  }
});

// Get vendor's available dates
router.get("/vendor-available-dates/:vendorId", async (req, res) => {
  try {
    const { vendorId } = req.params;
    const { startDate, endDate } = req.query;

    const query = {
      vendorId,
      isAvailable: true,
      date: {
        $gte: startDate ? new Date(startDate) : new Date(),
        ...(endDate && { $lte: new Date(endDate) }),
      },
    };

    const availableDates = await vendorAvailabilityModel
      .find(query)
      .select("date")
      .sort({ date: 1 });

    res.json({
      success: true,
      data: availableDates.map((a) => a.date),
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: `Error fetching available dates: ${error.message}`,
    });
  }
});

// Add this new endpoint for bulk updates
router.post("/vendor-availability/bulk-update", VerifyJWT, async (req, res) => {
  try {
    const { vendorId, dates, isAvailable, reason } = req.body;

    // Validate input
    if (!Array.isArray(dates) || dates.length === 0) {
      return res.status(400).json({
        success: false,
        message: "Please provide an array of dates",
      });
    }

    // Process all dates
    const updates = await Promise.all(
      dates.map(async (date) => {
        const availability = await vendorAvailabilityModel.findOneAndUpdate(
          { vendorId, date: new Date(date) },
          {
            $set: {
              isAvailable,
              reason,
              updatedAt: new Date(),
            },
          },
          { upsert: true, new: true }
        );
        return availability;
      })
    );

    res.json({
      success: true,
      message: `Successfully updated ${updates.length} dates`,
      data: updates,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: `Error updating availability: ${error.message}`,
    });
  }
});

module.exports = router;
