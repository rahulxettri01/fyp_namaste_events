
const express = require("express");
const mongoose = require("mongoose");
const app = express();
const PORT = 2000;
app.use(express.json());
app.use(express.urlencoded({ extended: true }));


const venueData = [];

//connect to mongoose
mongoose.set('strictQuery', true);

const venueAction = require("./routes/venueActions");
const userAuth = require("./routes/userRegistration");

app.use("/api", venueAction);
app.use("/auth", userAuth);


app.listen(PORT, () => {
    console.log(`Connected to server at port ${PORT}`);
});