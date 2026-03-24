import express from "express";
const router = express.Router();
import TodaysRecipe from "../models/TodaysRecipe.js";
import PantryItem from "../models/PantryItem.js";
import auth from "../middleware/auth.js";

// GET today's recipes for user
router.get('/:userId', auth, async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const todaysRecipes = await TodaysRecipe.find({
      userId: req.params.userId,
      plannedDate: { $gte: today, $lt: tomorrow }
    }).populate({
      path: 'recipeId',
      populate: {
        path: 'ingredients.itemId',
        select: 'name category'
      }
    });

    res.json(todaysRecipes.map(tr => tr.recipeId));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ADD recipe to today's plan
router.post('/', auth, async (req, res) => {
  try {
    const todaysRecipe = await TodaysRecipe.create({
      ...req.body,
      plannedDate: new Date()
    });
    const populated = await TodaysRecipe.findById(todaysRecipe._id)
      .populate({
        path: 'recipeId',
        populate: {
          path: 'ingredients.itemId',
          select: 'name category'
        }
      });
    res.status(201).json(populated.recipeId);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// GET missing ingredients for today's recipes
router.get('/:userId/missing-ingredients', auth, async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const todaysRecipes = await TodaysRecipe.find({
      userId: req.params.userId,
      plannedDate: { $gte: today, $lt: tomorrow }
    }).populate({
      path: 'recipeId',
      populate: {
        path: 'ingredients.itemId',
        select: 'name category'
      }
    });

    const pantryItems = await PantryItem.find({ userId: req.params.userId })
      .populate('itemId', 'name');

    const missingIngredients = [];

    for (const todaysRecipe of todaysRecipes) {
      const recipe = todaysRecipe.recipeId;
      for (const ingredient of recipe.ingredients) {
        const pantryItem = pantryItems.find(p => 
          p.itemId._id.toString() === ingredient.itemId._id.toString()
        );
        
        if (!pantryItem || pantryItem.quantity < ingredient.amount) {
          const needed = ingredient.amount - (pantryItem?.quantity || 0);
          missingIngredients.push({
            itemId: ingredient.itemId._id,
            itemName: ingredient.itemId.name,
            needed: needed,
            unit: ingredient.unit,
            recipeTitle: recipe.title
          });
        }
      }
    }

    res.json(missingIngredients);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// REMOVE recipe from today's plan
router.delete('/:userId/:recipeId', auth, async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    await TodaysRecipe.findOneAndDelete({
      userId: req.params.userId,
      recipeId: req.params.recipeId,
      plannedDate: { $gte: today, $lt: tomorrow }
    });
    res.json({ message: 'Recipe removed from today\'s plan' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

export default router;