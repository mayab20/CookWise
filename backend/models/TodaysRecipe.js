import mongoose from 'mongoose';

const todaysRecipeSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  recipeId: { type: mongoose.Schema.Types.ObjectId, ref: "Recipe", required: true },
  plannedDate: { type: Date, default: Date.now },
  isCompleted: { type: Boolean, default: false },
}, { timestamps: true });

// Ensure a user can't plan the same recipe twice for the same day
todaysRecipeSchema.index({ userId: 1, recipeId: 1, plannedDate: 1 }, { unique: true });

export default mongoose.model("TodaysRecipe", todaysRecipeSchema);