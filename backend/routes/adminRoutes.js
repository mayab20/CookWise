// routes/admin.js
import express from "express";
import User from "../models/User.js";
import Recipe from "../models/Recipe.js";
import Item from "../models/Item.js";
import PantryItem from "../models/PantryItem.js";
import auth from "../middleware/auth.js";
import admin from "../middleware/admin.js";

const router = express.Router();

router.get("/stats", auth, admin, async (req, res) => {
  try {
    console.log("ADMIN STATS ROUTE HIT");
    console.log(req.user);
    const stats = {
      users: await User.countDocuments(),
      recipes: await Recipe.countDocuments(),
      items: await Item.countDocuments(),
      pantryItems: await PantryItem.countDocuments(),
    };

    res.json(stats);
    console.log(req.user);
  } catch (err) {
    res.status(500).json({ error: "Failed to fetch stats" });
  }
});

// GET all recipes for admin
router.get("/recipes", auth, admin, async (req, res) => {
  try {
    const recipes = await Recipe.find()
      .populate("userId", "username")
      .populate("ingredients.itemId", "name")
      .sort({ createdAt: -1 });
    res.json(recipes);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});



// DELETE recipe (admin)
router.delete("/recipes/:recipeId", auth, admin, async (req, res) => {
  try {
    const recipe = await Recipe.findByIdAndDelete(req.params.recipeId);
    if (!recipe) return res.status(404).json({ error: "Recipe not found" });
    res.json({ message: "Recipe deleted" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;
