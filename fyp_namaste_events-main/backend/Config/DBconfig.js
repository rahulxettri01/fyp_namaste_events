const mongoose = require("mongoose");
const dotenv = require("dotenv");

dotenv.config();

const connectUserDB = () => {
  try {
    const conn = mongoose.connect(process.env.DATABASE_User).then(() => {
      console.log("User DB connected");
    });

    // console.log(`MongoDB Connected: ${conn.connection.host}`); // Success message with host
  } catch (error) {
    console.error(`Error: ${error.message}`); // Log the error message
    process.exit(1); // Exit process with failure code (1)
  }
};

const connectAdminDB = () => {
  try {
    const conn = mongoose.connect(process.env.DATABASE_Vendor).then(() => {
      console.log("admin DB connected");
    });

    // console.log(`MongoDB Connected: ${conn.connection.host}`); // Success message with host
  } catch (error) {
    console.error(`Error: ${error.message}`); // Log the error message
    process.exit(1); // Exit process with failure code (1)
  }
};

module.exports = { connectUserDB, connectAdminDB };
