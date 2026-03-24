import express from "express";
const router = express.Router();
import FavoriteRecipe from "../models/FavoriteRecipe.js";
import auth from "../middleware/auth.js";

// GET user's favorite recipes
router.get('/:userId', auth, async (req, res) => {
  try {
    const favorites = await FavoriteRecipe.find({ userId: req.params.userId })
      .populate('recipeId')
      .sort({ createdAt: -1 });
    res.json(favorites.map(fav => fav.recipeId));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ADD recipe to favorites
router.post('/', auth, async (req, res) => {
  try {
    const favorite = await FavoriteRecipe.create(req.body);
    const populatedFavorite = await FavoriteRecipe.findById(favorite._id)
      .populate('recipeId');
    res.status(201).json(populatedFavorite.recipeId);
  } catch (err) {
    if (err.code === 11000) {
      res.status(400).json({ error: 'Recipe already in favorites' });
    } else {
      res.status(400).json({ error: err.message });
    }
  }
});

// REMOVE recipe from favorites
router.delete('/:userId/:recipeId', auth, async (req, res) => {
  try {
    await FavoriteRecipe.findOneAndDelete({
      userId: req.params.userId,
      recipeId: req.params.recipeId
    });
    res.json({ message: 'Recipe removed from favorites' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

export default router;