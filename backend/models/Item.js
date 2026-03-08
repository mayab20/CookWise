import mongoose from 'mongoose';
import { ITEM_CATEGORY } from "../enums/ItemCategory.js";
import { UNIT } from "../enums/Unit.js";

const itemSchema = new mongoose.Schema({
  name: { type: String, required: true, unique: true },
  category: { type: String, enum: Object.values(ITEM_CATEGORY) },
  units: [{ type: String, enum: Object.values(UNIT) }], // Array of allowed units
}, { timestamps: true });

export default mongoose.model("Item", itemSchema);
