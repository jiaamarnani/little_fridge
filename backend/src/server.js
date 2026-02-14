require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { PrismaClient } = require('@prisma/client');

const authRouter = require('./routes/auth');
const foodsRouter = require('./routes/foods');
const fridgeRouter = require('./routes/fridge');

const app = express();
const prisma = new PrismaClient();

app.use(cors());
app.use(express.json());

app.use('/api/auth', authRouter);
app.use('/api/foods', foodsRouter);
app.use('/api/fridge', fridgeRouter);

app.get('/', (req, res) => {
  res.json({
    message: 'Little Fridge API',
    version: '1.0.0'
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// For local development
if (process.env.NODE_ENV !== 'production') {
  const PORT = process.env.PORT || 3000;
  app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
  });
}

// For Vercel (export the app)
module.exports = app;