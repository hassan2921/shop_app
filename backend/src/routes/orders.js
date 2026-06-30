const express = require('express');
const Order = require('../models/Order');
const Cart = require('../models/Cart');
const authMiddleware = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);

// POST /api/orders — create order from submitted cart snapshot
router.post('/', async (req, res) => {
  try {
    const { items, total } = req.body;
    if (!items || items.length === 0) {
      return res.status(400).json({ message: 'No items provided' });
    }
    const order = await Order.create({ userId: req.user.id, items, total });
    // Clear the cart now that the order is placed.
    await Cart.findOneAndUpdate({ userId: req.user.id }, { items: [] }, { upsert: true });
    res.status(201).json({ order });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET /api/orders — get the authenticated user's orders
router.get('/', async (req, res) => {
  try {
    const orders = await Order.find({ userId: req.user.id }).sort({ createdAt: -1 });
    res.json({ orders });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET /api/orders/:id — single order (must belong to caller)
router.get('/:id', async (req, res) => {
  try {
    const order = await Order.findOne({ _id: req.params.id, userId: req.user.id });
    if (!order) return res.status(404).json({ message: 'Order not found' });
    res.json({ order });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
