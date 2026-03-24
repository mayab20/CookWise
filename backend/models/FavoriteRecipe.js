import mongoose from 'mongoose';

const favoriteRecipeSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  recipeId: { type: mongoose.Schema.Types.ObjectId, ref: "Recipe", required: true },
}, { timestamps: true });


favoriteRecipeSchema.index({ userId: 1, recipeId: 1 }, { unique: true });

export default mongoose.model("FavoriteRecipe", favoriteRecipeSchema);