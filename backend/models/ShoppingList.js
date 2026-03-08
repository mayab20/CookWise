import mongoose from 'mongoose';

const shoppingListSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },

  items: [{
    itemId: { type: mongoose.Schema.Types.ObjectId, ref: "Item", required: true },
    
    quantity: {type: Number, required: true },
    checked: { type: Boolean, default: false },
  }]

}, { timestamps: true });

export default mongoose.model("ShoppingList", shoppingListSchema);
