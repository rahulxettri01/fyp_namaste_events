const multer = require("multer");
const path = require("path");

// Configure storage with unique filename using date-time
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "./uploads/"); // Directory where files will be stored
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
const upload = multer({ storage });

module.exports = upload;
