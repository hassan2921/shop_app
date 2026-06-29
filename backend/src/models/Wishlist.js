const mongoose = require('mongoose');

const wishlistSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', unique: true, required: true },
    productIds: [String],
  },
  { timestamps: true }
);

module.exports = mongoose.model('Wishlist', wishlistSchema);
