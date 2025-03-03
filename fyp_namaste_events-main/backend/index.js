const express = require("express");

const app = express();
const PORT = 2000;
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const venueData = [];

app.listen(PORT, () => {
    console.log(`Connected to server at port ${PORT}`);
});

// POST API to add venue
app.post("/api/add_venue", (req, res) => {
    console.log("back hit");

    const vdata = {
        id: venueData.length + 1,
        venue_name: req.body.venue_name,
        venue_price: req.body.venue_price,
        venue_rating: req.body.venue_rating
    };

    venueData.push(vdata);
    console.log("Final", vdata);
    console.log("Endpoint hit");

    res.status(200).send({
        status_code: 200,
        message: "Venue added successfully",
        venue: vdata
    });
});

// GET API to fetch venues
app.get("/api/get_venue", (req, res) => {
    res.status(200).send({
        status_code: 200,
        venues: venueData
    });
});

// UPDATE API
app.put("/api/update/:id", (req, res) => {
    let id = parseInt(req.params.id);
    let venueToUpdate = venueData.find(v => v.id === id);

    if (!venueToUpdate) {
        return res.status(404).send({
            status: "error",
            message: "Venue not found"
        });
    }

    // Update only provided fields
    venueToUpdate.venue_name = req.body.venue_name || venueToUpdate.venue_name;
    venueToUpdate.venue_price = req.body.venue_price || venueToUpdate.venue_price;
    venueToUpdate.venue_rating = req.body.venue_rating || venueToUpdate.venue_rating;

    res.status(200).send({
        status: "success",
        message: "Venue updated",
        venue: venueToUpdate
    });
});

// DELETE API
app.delete("/api/delete/:id", (req, res) => {
    let id = parseInt(req.params.id);
    let venueIndex = venueData.findIndex(v => v.id === id);

    if (venueIndex === -1) {
        return res.status(404).send({
            status: "error",
            message: "Venue not found"
        });
    }

    venueData.splice(venueIndex, 1);

    res.status(200).send({
        status: "success",
        message: "Venue deleted"
    });
});
