const express = require('express');
const Cart = require('../models/Cart');
const Product = require('../models/Product');
const authMiddleware = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);

// Fetch cart items with full product data populated.
async function populatedItems(userId) {
  const cart = await Cart.findOne({ userId });
  if (!cart || cart.items.length === 0) return [];

  const ids = [...new Set(cart.items.map((i) => i.productId))];
  const productDocs = await Product.find({ id: { $in: ids } }, '-_id -__v');
  const byId = Object.fromEntries(productDocs.map((p) => [p.id, p.toObject()]));

  return cart.items
    .filter((i) => byId[i.productId])
    .map((i) => ({
      productId: i.productId,
      product: byId[i.productId],
      size: i.size,
      color: i.color,
      quantity: i.quantity,
    }));
}

function sameItem(i, productId, size, color) {
  return i.productId === productId && i.size === size && i.color === (color ?? null);
}

// GET /api/cart
router.get('/', async (req, res) => {
  try {
    res.json({ items: await populatedItems(req.user.id) });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/cart/add
router.post('/add', async (req, res) => {
  try {
    const { productId, size, color = null } = req.body;
    let cart = await Cart.findOne({ userId: req.user.id });
    if (!cart) cart = new Cart({ userId: req.user.id, items: [] });

    const idx = cart.items.findIndex((i) => sameItem(i, productId, size, color));
    if (idx >= 0) {
      cart.items[idx].quantity += 1;
    } else {
      cart.items.push({ productId, size, color, quantity: 1 });
    }
    await cart.save();
    res.json({ items: await populatedItems(req.user.id) });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/cart/increment
router.post('/increment', async (req, res) => {
  try {
    const { productId, size, color = null } = req.body;
    const cart = await Cart.findOne({ userId: req.user.id });
    if (!cart) return res.json({ items: [] });

    const idx = cart.items.findIndex((i) => sameItem(i, productId, size, color));
    if (idx >= 0) cart.items[idx].quantity += 1;
    await cart.save();
    res.json({ items: await populatedItems(req.user.id) });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/cart/decrement
router.post('/decrement', async (req, res) => {
  try {
    const { productId, size, color = null } = req.body;
    const cart = await Cart.findOne({ userId: req.user.id });
    if (!cart) return res.json({ items: [] });

    const idx = cart.items.findIndex((i) => sameItem(i, productId, size, color));
    if (idx >= 0) {
      if (cart.items[idx].quantity <= 1) {
        cart.items.splice(idx, 1);
      } else {
        cart.items[idx].quantity -= 1;
      }
    }
    await cart.save();
    res.json({ items: await populatedItems(req.user.id) });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// DELETE /api/cart/remove
router.delete('/remove', async (req, res) => {
  try {
    const { productId, size, color = null } = req.body;
    const cart = await Cart.findOne({ userId: req.user.id });
    if (!cart) return res.json({ items: [] });

    cart.items = cart.items.filter((i) => !sameItem(i, productId, size, color));
    await cart.save();
    res.json({ items: await populatedItems(req.user.id) });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// DELETE /api/cart/clear
router.delete('/clear', async (req, res) => {
  try {
    await Cart.findOneAndUpdate(
      { userId: req.user.id },
      { items: [] },
      { upsert: true, new: true }
    );
    res.json({ items: [] });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
