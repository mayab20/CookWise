import express from "express";
import PantryItem from "../models/PantryItem.js";
import auth from "../middleware/auth.js";

const router = express.Router();

// GET all pantry items for a user
router.get("/:userId", auth, async (req, res) => {
  try {
    const items = await PantryItem
      .find({ userId: req.params.userId })
      .populate('itemId', 'name category')
      .sort({ createdAt: -1 });

    res.json(items);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ADD a pantry item
router.post("/", auth, async (req, res) => {
  try {
    const item = await PantryItem.create(req.body);
    const populatedItem = await PantryItem.findById(item._id).populate('itemId', 'name category');
    res.status(201).json(populatedItem);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// UPDATE item
router.put("/:itemId", auth, async (req, res) => {
  try {
    const item = await PantryItem.findByIdAndUpdate(
      req.params.itemId,
      req.body,
      { new: true }
    ).populate('itemId', 'name category');

    if (!item) {
      return res.status(404).json({ error: "Item not found" });
    }

    res.json(item);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// DELETE item
router.delete("/:itemId", auth, async (req, res) => {
  try {
    const item = await PantryItem.findByIdAndDelete(req.params.itemId);

    if (!item) {
      return res.status(404).json({ error: "Item not found" });
    }

    res.json({ message: "Item deleted" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;
