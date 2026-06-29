const express = require('express');
const Wishlist = require('../models/Wishlist');
const Product = require('../models/Product');
const authMiddleware = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);

async function wishlistProducts(userId) {
  const wl = await Wishlist.findOne({ userId });
  if (!wl || wl.productIds.length === 0) return [];
  return Product.find({ id: { $in: wl.productIds } }, '-_id -__v');
}

// GET /api/wishlist
router.get('/', async (req, res) => {
  try {
    res.json({ products: await wishlistProducts(req.user.id) });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/wishlist/toggle
router.post('/toggle', async (req, res) => {
  try {
    const { productId } = req.body;
    let wl = await Wishlist.findOne({ userId: req.user.id });
    if (!wl) wl = new Wishlist({ userId: req.user.id, productIds: [] });

    const idx = wl.productIds.indexOf(productId);
    if (idx >= 0) {
      wl.productIds.splice(idx, 1);
    } else {
      wl.productIds.push(productId);
    }
    await wl.save();
    res.json({ products: await wishlistProducts(req.user.id) });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
