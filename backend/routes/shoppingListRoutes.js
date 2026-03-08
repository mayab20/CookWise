import express from "express";
const router = express.Router();
import ShoppingListItem from "../models/ShoppingListItem.js";
import auth from "../middleware/auth.js";

// GET shopping list items for user
router.get('/:userId', auth, async (req, res) => {
  try {
    const items = await ShoppingListItem.find({ userId: req.params.userId })
      .populate('itemId', 'name category')
      .sort({ createdAt: -1 });
    res.json(items);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ADD shopping list item
router.post('/', auth, async (req, res) => {
  try {
    console.log('Adding shopping list item:', req.body);
    const item = await ShoppingListItem.create(req.body);
    console.log('Created item:', item);
    const populatedItem = await ShoppingListItem.findById(item._id)
      .populate('itemId', 'name category');
    console.log('Populated item:', populatedItem);
    res.status(201).json(populatedItem);
  } catch (err) {
    console.error('Error adding shopping list item:', err);
    res.status(400).json({ error: err.message });
  }
});

// UPDATE shopping list item
router.put('/:itemId', auth, async (req, res) => {
  try {
    const item = await ShoppingListItem.findByIdAndUpdate(
      req.params.itemId,
      req.body,
      { new: true }
    ).populate('itemId', 'name category');
    res.json(item);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// DELETE shopping list item
router.delete('/:itemId', auth, async (req, res) => {
  try {
    await ShoppingListItem.findByIdAndDelete(req.params.itemId);
    res.json({ message: 'Item deleted successfully' });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

export default router;
