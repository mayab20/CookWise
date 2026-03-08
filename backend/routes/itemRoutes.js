import express from "express";
import Item from "../models/Item.js";
import auth from "../middleware/auth.js";

const router = express.Router();

// GET all items
router.get("/", auth, async (req, res) => {
  try {
    const items = await Item.find().sort({ name: 1 }); // sort A-Z
    res.json(items);
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch items" });
  }
});

// ADD a new item (only admin)
router.post("/", auth, async (req, res) => {
  try {
    const { name, category, units } = req.body;

    const existing = await Item.findOne({ name });
    if (existing) {
      return res.status(400).json({ error: "Item already exists" });
    }

    const newItem = new Item({
      name,
      category,
      units: units || [], // Default to empty array if no units provided
    });

    await newItem.save();
    res.status(201).json(newItem);
  } catch (error) {
    res.status(500).json({ error: "Failed to add item" });
  }
});

// UPDATE an item
router.put("/:id", auth, async (req, res) => {
  try {
    const { name, category, units } = req.body;

    const updated = await Item.findByIdAndUpdate(
      req.params.id,
      { name, category, units },
      { new: true }
    );

    if (!updated) {
      return res.status(404).json({ error: "Item not found" });
    }

    res.json(updated);
  } catch (error) {
    res.status(500).json({ error: "Failed to update item" });
  }
});

// DELETE an item
router.delete("/:id", auth, async (req, res) => {
  try {
    const deleted = await Item.findByIdAndDelete(req.params.id);
    if (!deleted) {
      return res.status(404).json({ error: "Item not found" });
    }
    res.json({ message: "Item deleted" });
  } catch (error) {
    res.status(500).json({ error: "Failed to delete item" });
  }
});

export default router;
