const express = require("express");
const router = express.Router();

const venueData = [];

// POST API to add venue
router.post("/add_venue", (req, res) => {
  console.log("back hit");

  const vdata = {
    id: venueData.length + 1,
    venue_name: req.body.venue_name,
    venue_price: req.body.venue_price,
    venue_rating: req.body.venue_rating,
  };

  venueData.push(vdata);
  console.log("Final", vdata);
  console.log("Endpoint hit");

  res.status(200).send({
    status_code: 200,
    message: "Venue added successfully",
    venue: vdata,
  });
});

// GET API to fetch venues
router.get("/get_venue", (req, res) => {
  res.status(200).send({
    status_code: 200,
    venues: venueData,
  });
});

// UPDATE API
router.put("/update/:id", (req, res) => {
  let id = parseInt(req.params.id);
  let venueToUpdate = venueData.find((v) => v.id === id);

  if (!venueToUpdate) {
    return res.status(404).send({
      status: "error",
      message: "Venue not found",
    });
  }

  // Update only provided fields
  venueToUpdate.venue_name = req.body.venue_name || venueToUpdate.venue_name;
  venueToUpdate.venue_price = req.body.venue_price || venueToUpdate.venue_price;
  venueToUpdate.venue_rating =
    req.body.venue_rating || venueToUpdate.venue_rating;

  res.status(200).send({
    status: "success",
    message: "Venue updated",
    venue: venueToUpdate,
  });
});

// DELETE API
router.delete("/delete/:id", (req, res) => {
  let id = parseInt(req.params.id);
  let venueIndex = venueData.findIndex((v) => v.id === id);

  if (venueIndex === -1) {
    return res.status(404).send({
      status: "error",
      message: "Venue not found",
    });
  }

  venueData.splice(venueIndex, 1);

  res.status(200).send({
    status: "success",
    message: "Venue deleted",
  });
});

module.exports = router;
