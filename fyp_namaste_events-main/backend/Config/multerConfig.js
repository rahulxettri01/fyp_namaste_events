const multer = require("multer");
const path = require("path");
const { connectInventoryDB, connectUserDB } = require("../Config/DBconfig");
const {
  docImageModel,
  photographyImageModel,
  venueImageModel,
  decorationImageModel,
} = require("../models/image");

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
    console.log("details", details);

    const image = new docImageModel({
      fileName: uniqueName,
      filePath: "uploads/vendor",
      srcFrom: details["email"],
      type: "verification",
    });
    await connectInventoryDB(async () => {
      await image.save().then(() => {
        req.imageStatus = true;
        console.log("image uploaded");
      });
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

// Configure storage for inventory images
const storageInventory = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "./uploads/inventory"); // Directory where files will be stored
  },
  filename: async (req, file, cb) => {
    const ext = path.extname(file.originalname);
    const uniqueName =
      path.basename(file.originalname, ext) + "-" + Date.now() + ext;

    const details = req.user;
    console.log("inventory upload details", details);
    let image;
    if (details.category === "Photography") {
      image = new photographyImageModel({
        fileName: uniqueName,
        filePath: "uploads/inventory",
        srcFrom: details.email,
        type: "photography",
      });
      console.log("photo");
    } else if (details.category === "Venue") {
      image = new venueImageModel({
        fileName: uniqueName,
        filePath: "uploads/inventory",
        srcFrom: details.email,
        type: "venue",
      });
    } else if (details.category === "Decoration") {
      image = new decorationImageModel({
        fileName: uniqueName,
        filePath: "uploads/inventory",
        srcFrom: details.email,
        type: "decoration",
      });
    }

    await connectInventoryDB(async () => {
      await image.save().then(() => {
        console.log("inventory image uploaded");
      });
    });

    cb(null, uniqueName);
  },
});

// Initialize Multer upload
const uploadVendor = multer({ storage: storageVendor });
const uploadUser = multer({ storage: storageUser });
const uploadInventory = multer({ storage: storageInventory });

module.exports = { uploadUser, uploadVendor, uploadInventory };
