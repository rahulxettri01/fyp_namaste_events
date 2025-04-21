const mongoose = require("mongoose");

const AvailabilitySchema = new mongoose.Schema(
  {
    availabilityID: {
      type: mongoose.Schema.Types.ObjectId,
      unique: true,
      default: () => new mongoose.Types.ObjectId(),
    },
    vendorEmail: {
      type: String,
      required: true,
    },
    // serviceEmail: {
    //   type: String,
    //   required: true,
    // },
    // date: { type: Date, required: true },
    startDate: { type: String, required: true },
    endDate: { type: String, required: true },
    category: {
      type: String,
      required: true,
      enum: ["Photography", "Venue", "Decorator"],
    },
    status: {
      type: String,
      required: true,
      enum: ["Available", "Booked"],
      default: "Available",
    },
  },
  { timestamps: true }
);

const AvailabilityModel = mongoose.model("Availability", AvailabilitySchema);
module.exports = { AvailabilityModel };
