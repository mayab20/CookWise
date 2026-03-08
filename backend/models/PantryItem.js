import mongoose from 'mongoose';

const pantryItemSchema = new mongoose.Schema({
  userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    itemId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Item",
      required: true,
    },
    quantity: {
      type: Number,
      required: true,
    },
    unit: {
      type: String,
      required: true,
      default: 'pcs'
    },
  
  expirationDate: { type: Date },  
  imageUrl: { type: String },       

  nutrition: {
    calories: Number,
    protein: Number,
    carbs: Number,
    fat: Number
  }
  
}, { timestamps: true });

export default mongoose.model("Pantry", pantryItemSchema);
