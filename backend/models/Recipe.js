import mongoose from 'mongoose';
import { RECIPE_CATEGORY } from "../enums/RecipeCategory.js";
import { RECIPE_CUISINE } from "../enums/RecipeCuisine.js";

const ingredientSchema = new mongoose.Schema({
  itemId: { type: mongoose.Schema.Types.ObjectId, ref: "Item", required: true },
  amount: { type: Number, required: true },
  unit: { type: String, required: true }
});

const recipeSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User" },

  title: { type: String, required: true },
  description: String,
  imageUrl: String,

  ingredients: { type: [ingredientSchema], required: true },

  steps: { type: [String], required:true },

  readyInMinutes: { type: Number, required: true },
  servings: Number,
  category: { type: String, enum: Object.values(RECIPE_CATEGORY), required: true }, 
  cuisine: { type: String, enum: Object.values(RECIPE_CUISINE), required: true },  

  // Optional: help in recommendations
  tags: [String],

}, { timestamps: true });

export default mongoose.model("Recipe", recipeSchema);
