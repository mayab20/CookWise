import express from "express";
import Recipe from "../models/Recipe.js";
import auth from "../middleware/auth.js"; 

const router = express.Router();

// GET all recipes (for home page)
router.get("/", auth, async (req, res) => {
  try {
    const recipes = await Recipe.find({})
      .sort({ createdAt: -1 })
      .populate("ingredients.itemId", "name unit");
    res.json(recipes);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET all recipes for a user (newest first)
router.get("/user/:userId", auth, async (req, res) => {
  try {
    const recipes = await Recipe.find({ userId: req.params.userId })
      .sort({ createdAt: -1 })
      .populate("ingredients.itemId", "name unit"); // send name + unit
    res.json(recipes);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET a single recipe
router.get("/:recipeId", auth, async (req, res) => {
  try {
    const recipe = await Recipe.findById(req.params.recipeId)
      .populate("ingredients.itemId", "name unit");
    if (!recipe) return res.status(404).json({ error: "Recipe not found" });
    res.json(recipe);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ADD a new recipe
router.post("/", auth, async (req, res) => {
  try {
    const recipe = await Recipe.create(req.body);
    res.status(201).json(recipe);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// UPDATE a recipe
router.put("/:recipeId", auth, async (req, res) => {
  try {
    const recipe = await Recipe.findByIdAndUpdate(
      req.params.recipeId,
      req.body,
      { new: true }
    );
    if (!recipe) return res.status(404).json({ error: "Recipe not found" });
    res.json(recipe);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// DELETE a recipe
router.delete("/:recipeId", auth, async (req, res) => {
  try {
    const recipe = await Recipe.findByIdAndDelete(req.params.recipeId);
    if (!recipe) return res.status(404).json({ error: "Recipe not found" });
    res.json({ message: "Recipe deleted" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;
