require('dotenv').config();
const mongoose = require('mongoose');
const app = require('./src/app');

const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/shopapp';

mongoose
  .connect(MONGO_URI)
  .then(async () => {
    console.log('MongoDB connected');
    await seedProducts();
    app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
  })
  .catch((err) => {
    console.error('MongoDB connection failed:', err.message);
    process.exit(1);
  });

async function seedProducts() {
  const Product = require('./src/models/Product');
  const count = await Product.countDocuments();
  if (count > 0) return;

  await Product.insertMany([
    {
      id: '0',
      title: "Men's Nike Shoes",
      price: 44.52,
      imageUrl: 'assets/images/shoes_1.png',
      company: 'Nike',
      sizes: [9, 10, 11, 12],
      colors: [0xff000000, 0xffffffff, 0xff4caf50],
      description:
        'Iconic Nike design with superior cushioning and breathable mesh upper. Perfect for everyday wear and light athletic activities.',
    },
    {
      id: '1',
      title: 'Adidas Shoes',
      price: 20.12,
      imageUrl: 'assets/images/shoes_2.png',
      company: 'Adidas',
      sizes: [9, 10, 12],
      colors: [0xff2196f3, 0xff000000, 0xffff5722],
      description:
        'Classic Adidas style with responsive Boost technology. Lightweight construction ensures all-day comfort.',
    },
    {
      id: '2',
      title: "Bata Women's Shoes",
      price: 28.95,
      imageUrl: 'assets/images/shoes_3.png',
      company: 'Bata',
      sizes: [8, 9, 10],
      colors: [0xffe91e63, 0xff9c27b0, 0xffffffff],
      description:
        "Elegant Bata women's footwear combining style and comfort. Durable sole with premium finishing.",
    },
    {
      id: '3',
      title: 'Jordan Shoes',
      price: 420.69,
      imageUrl: 'assets/images/shoes_4.png',
      company: 'Nike',
      sizes: [8, 9, 10],
      colors: [0xfff44336, 0xff000000, 0xffffeb3b],
      description:
        'Premium Air Jordan silhouette with iconic colorway. Genuine leather upper with Air-Sole cushioning unit.',
    },
  ]);
  console.log('Products seeded');
}
