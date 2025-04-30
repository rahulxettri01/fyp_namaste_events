import mongoose from 'mongoose';

const bookingSchema = new mongoose.Schema({
    customerID: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Customer',
        required: true
    },
    artistID: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Artist',
        required: true
    },
    serviceID: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Service',
        required: true
    },
    availabilityID: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Availability',
        required: true
    },
    price: {
        type: Number,
        required: true
    },
    paymentMethod: { 
        type: String, 
        enum: ["Khalti", "khalti"], 
        required: true 
    },
    bookingStatus: {
        type: String,
        default: 'Pending'
    },
    paymentStatus: {
        type: String,
        default: 'Pending'
    },
    status: {
        type: String,
        enum: ['active', 'completed', 'canceled'],
        default: 'active'
    },

}, { timestamps: true });

const Booking = mongoose.model('Booking', bookingSchema);
export default Booking;