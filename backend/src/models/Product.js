const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  id: { type: String, required: true, unique: true },
  title: { type: String, required: true },
  price: { type: Number, required: true },
  imageUrl: { type: String, required: true },
  company: { type: String, required: true },
  sizes: [Number],
  colors: [Number],
  description: { type: String, default: '' },
});

module.exports = mongoose.model('Product', productSchema);
