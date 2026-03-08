import mongoose from 'mongoose';

const shoppingListItemSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  itemId: { type: mongoose.Schema.Types.ObjectId, ref: "Item", required: true },
  quantity: { type: Number, required: true },
  unit: { type: String, required: true },
  isCompleted: { type: Boolean, default: false },
}, { timestamps: true });

export default mongoose.model("ShoppingListItem", shoppingListItemSchema);