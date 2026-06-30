const mongoose = require('mongoose');

const CATEGORIES = ['Shoes', 'Clothing', 'Accessories', 'Electronics', 'Sports', 'Other'];

const productSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  title: { type: String, required: true },
  price: { type: Number, required: true },
  imageUrl: { type: String, required: true },
  company: { type: String, required: true },
  category: { type: String, enum: CATEGORIES, default: 'Other' },
  sizes: [Number],
  colors: [Number],
  description: { type: String, default: '' },
});

module.exports = mongoose.model('Product', productSchema);
