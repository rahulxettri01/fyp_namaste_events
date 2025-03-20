const mongoose = require("mongoose");
const dotenv = require("dotenv");

dotenv.config();

const connectUserDB = () => {
  try {
    mongoose.connect(process.env.DATABASE_User).then(() => {
      console.log("User DB connected");
    });
  } catch (error) {
    console.error(`Error: ${error.message}`); // Log the error message
    process.exit(1); // Exit process with failure code (1)
  }
};

const connectInventoryDB = () => {
  try {
    mongoose.connect(process.env.DATABASE_Vendor).then(() => {
      console.log("Inventory DB connected");
    });
  } catch (error) {
    console.error(`Error: ${error.message}`); // Log the error message
    process.exit(1); // Exit process with failure code (1)
  }
};

const connectSuperAdminDB = () => {
  try {
    mongoose.connect(process.env.DATABASE_Super_Admin).then(() => {
      console.log("Super Admin DB connected");
    });
  } catch (error) {
    console.error(`Error: ${error.message}`); // Log the error message
    process.exit(1); // Exit process with failure code (1)
  }
};

module.exports = {
  connectUserDB,
  connectInventoryDB,
  connectSuperAdminDB,
};
