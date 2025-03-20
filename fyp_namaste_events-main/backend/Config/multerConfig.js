const multer = require("multer");
const path = require("path");
const { connectInventoryDB, connectUserDB } = require("../Config/DBconfig");
const { docImageModel } = require("../models/image");

// Configure storage with unique filename using date-time
const storageVendor = multer.diskStorage({
  // connectAdminDB
  destination: (req, file, cb) => {
    console.log("vn mul");
    cb(null, "./uploads/vendor"); // Directory where files will be stored
  },
  filename: async (req, file, cb) => {
    // Extract file extension
    const ext = path.extname(file.originalname);
    // Generate a unique filename: originalName_without_extension + timestamp + extension
    const uniqueName =
      path.basename(file.originalname, ext) + "-" + Date.now() + ext;
    const details = req.user;

    const image = new docImageModel({
      fileName: uniqueName,
      filePath: "uploads/vendor",
      srcFrom: details["email"],
      type: "verification",
    });
    connectInventoryDB(async () => {
      await image.save().then(() => {});
    });
    cb(null, uniqueName);
  },
});
const storageUser = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "./uploads/user"); // Directory where files will be stored
  },
  filename: (req, file, cb) => {
    // Extract file extension
    const ext = path.extname(file.originalname);
    // Generate a unique filename: originalName_without_extension + timestamp + extension
    const uniqueName =
      path.basename(file.originalname, ext) + "-" + Date.now() + ext;
    const image = new docImageModel({
      fileName: uniqueName,
      filePath: "uploads/user",
      srcFrom: "user",
    });
    cb(null, uniqueName);
  },
});

const storageInventory = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "./uploads/inventory"); // Directory where files will be stored
  },
  filename: (req, file, cb) => {
    // Extract file extension
    const ext = path.extname(file.originalname);
    // Generate a unique filename: originalName_without_extension + timestamp + extension
    const uniqueName =
      path.basename(file.originalname, ext) + "-" + Date.now() + ext;
    cb(null, uniqueName);
  },
});

// Initialize Multer upload
const uploadVendor = multer({ storage: storageVendor });
const uploadUser = multer({ storage: storageUser });
const uploadInventory = multer({ storage: storageInventory });

module.exports = { uploadUser, uploadVendor, uploadInventory };
