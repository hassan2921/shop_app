const express = require('express');
const Category = require('../models/Category');

const router = express.Router();

// GET /api/categories — public, used by customer app for filter chips
router.get('/', async (req, res) => {
  try {
    const categories = await Category.find({}).sort({ name: 1 }).select('name');
    res.json({ categories });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
