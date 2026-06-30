const path = require('path');
const express = require('express');
const multer = require('multer');
const Order = require('../models/Order');
const Product = require('../models/Product');
const Category = require('../models/Category');
const adminAuth = require('../middleware/adminAuth');

const router = express.Router();
router.use(adminAuth);

const storage = multer.diskStorage({
  destination: path.join(__dirname, '../../../uploads'),
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `${Date.now()}-${Math.random().toString(36).slice(2)}${ext}`);
  },
});
const upload = multer({ storage, limits: { fileSize: 5 * 1024 * 1024 } });

// ─── Image upload ───────────────────────────────────────────────────────────

// POST /api/admin/upload
router.post('/upload', upload.single('image'), (req, res) => {
  if (!req.file) return res.status(400).json({ message: 'No file uploaded' });
  const url = `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}`;
  res.json({ url });
});

// ─── Categories ─────────────────────────────────────────────────────────────

// GET /api/admin/categories
router.get('/categories', async (req, res) => {
  try {
    const categories = await Category.find({}).sort({ name: 1 });
    res.json({ categories });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/admin/categories
router.post('/categories', async (req, res) => {
  try {
    const { name } = req.body;
    if (!name || !name.trim()) return res.status(400).json({ message: 'name is required' });
    const category = await Category.create({ name: name.trim() });
    res.status(201).json({ category });
  } catch (err) {
    if (err.code === 11000) return res.status(409).json({ message: 'Category already exists' });
    res.status(500).json({ message: err.message });
  }
});

// DELETE /api/admin/categories/:id
router.delete('/categories/:id', async (req, res) => {
  try {
    const category = await Category.findByIdAndDelete(req.params.id);
    if (!category) return res.status(404).json({ message: 'Category not found' });
    res.json({ message: 'Category deleted' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

const VALID_STATUSES = ['pending', 'processing', 'shipped', 'delivered'];

// ─── Orders ────────────────────────────────────────────────────────────────

// GET /api/admin/orders — all orders with user info
router.get('/orders', async (req, res) => {
  try {
    const orders = await Order.find({})
      .sort({ createdAt: -1 })
      .populate('userId', 'name email');
    res.json({ orders });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// PATCH /api/admin/orders/:id/status — update a single order's status
router.patch('/orders/:id/status', async (req, res) => {
  try {
    const { status } = req.body;
    if (!VALID_STATUSES.includes(status)) {
      return res.status(400).json({ message: `status must be one of: ${VALID_STATUSES.join(', ')}` });
    }
    const order = await Order.findByIdAndUpdate(req.params.id, { status }, { new: true })
      .populate('userId', 'name email');
    if (!order) return res.status(404).json({ message: 'Order not found' });
    res.json({ order });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// ─── Products ──────────────────────────────────────────────────────────────

// GET /api/admin/products
router.get('/products', async (req, res) => {
  try {
    const products = await Product.find({}, '-__v');
    res.json({ products });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/admin/products
router.post('/products', async (req, res) => {
  try {
    const { id, title, price, imageUrl, company, category, sizes = [], colors = [], description = '' } = req.body;
    if (!id || !title || !price || !imageUrl || !company || !category) {
      return res.status(400).json({ message: 'id, title, price, imageUrl, company and category are required' });
    }
    if (await Product.findOne({ id })) {
      return res.status(409).json({ message: 'A product with that id already exists' });
    }
    const product = await Product.create({ id, title, price, imageUrl, company, category, sizes, colors, description });
    res.status(201).json({ product });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// PUT /api/admin/products/:id
router.put('/products/:id', async (req, res) => {
  try {
    const { title, price, imageUrl, company, category, sizes, colors, description } = req.body;
    const product = await Product.findOneAndUpdate(
      { id: req.params.id },
      { title, price, imageUrl, company, category, sizes, colors, description },
      { new: true, runValidators: true }
    );
    if (!product) return res.status(404).json({ message: 'Product not found' });
    res.json({ product });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// DELETE /api/admin/products/:id
router.delete('/products/:id', async (req, res) => {
  try {
    const product = await Product.findOneAndDelete({ id: req.params.id });
    if (!product) return res.status(404).json({ message: 'Product not found' });
    res.json({ message: 'Product deleted' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
