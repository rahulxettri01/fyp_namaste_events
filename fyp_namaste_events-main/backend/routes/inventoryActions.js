const express = require("express");
const VerifyJWT = require("../middleware/VerifyJWT");
const router = express.Router();
const { connectInventoryDB } = require("../Config/DBconfig");
const { venueModel } = require("../models/venue");
const { decoratorModel } = require("../models/decoration");
const { photographyModel } = require("../models/photography");

const venueData = [];

// POST API to add venue
router.post("/add_inventory", VerifyJWT, async (req, res) => {
  console.log("back hit");

  const vdata = {
    inventoryName: req.body.inventoryName,
    address: req.body.address,
    price: req.body.price,
    description: req.body.description,
    accommodation: req.body.accommodation,
    image: req.file ? req.file.path : null,
  };

  venueData.push(vdata);
  let existInventory = null;

  console.log(vdata);

  vdata.venueName = vdata.inventoryName;
  delete vdata.inventoryName;
  console.log("after", vdata);

  let category = req.user["category"];

  if (category == "Venue") {
    connectInventoryDB(async () => {
      existInventory = await venueModel.findOne({
        venueName: vdata.venueName,
      });
    });
    console.log("vay", existInventory);

    if (existInventory) {
      console.log("flop");
      //    return res.status(400).send("User already exists. Please sign in");
      return res.status(400).json({
        status_code: 400,
        message: "Venue already exists. Please check details",
      });
    } else {
      console.log("new");

      const newVenue = new venueModel(vdata);

      connectInventoryDB(async () => {
        newVenue.save().then(() => {
          console.log("success");

          return res.status(200).send({
            status_code: 200,
            message: "Venue added successfully",
          });
        });
      });
    }
  } else if (category == "Decoration") {
    connectInventoryDB(async () => {
      existInventory = await decoratorModel.findOne({
        decoratorName: vdata.inventoryName,
      });
    });

    if (existInventory) {
      //    return res.status(400).send("User already exists. Please sign in");
      return res.status(400).json({
        status_code: 400,
        message: "Decorator already exists. Please check details",
      });
    } else {
      const newDecorator = new decoratorModel(vdata);

      connectInventoryDB(async () => {
        newDecorator.save().then(() => {
          return res.status(200).send({
            status_code: 200,
            message: "Decorator added successfully",
          });
        });
      });
    }
  } else if (category == "Photography") {
    connectInventoryDB(async () => {
      existInventory = await photographyModel.findOne({
        photographyName: vdata.inventoryName,
      });
    });
    if (existInventory) {
      //    return res.status(400).send("User already exists. Please sign in");
      return res.status(400).json({
        status_code: 400,
        message: "Photographer already exists. Please check details",
      });
    } else {
      const newPhotographer = new photographyModel(vdata);

      connectInventoryDB(async () => {
        newPhotographer.save().then(() => {
          return res.status(200).send({
            status_code: 200,
            message: "Photographer added successfully",
          });
        });
      });
    }
  }
});

// GET API to fetch all venues
router.get("/get_inventory", VerifyJWT, async (req, res) => {
  try {
    let venues = null;
    connectInventoryDB(async () => {
      venues = await venueModel.find();
    });

    return res.status(200).json({
      success: true,
      data: venues,
    });
  } catch (error) {
    console.error("Error fetching venues:", error);
    return res.status(500).json({
      success: false,
      message: "Server error while fetching inventory",
    });
  }
});

module.exports = router;
