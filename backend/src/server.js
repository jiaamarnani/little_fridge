require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { PrismaClient } = require('@prisma/client');

const authRouter = require('./routes/auth');
const foodsRouter = require('./routes/foods');
const fridgeRouter = require('./routes/fridge');

const app = express();
const prisma = new PrismaClient();
const PORT = process.env.PORT || 8080;

app.use(cors());
app.use(express.json());

app.use('/api/auth', authRouter);
app.use('/api/foods', foodsRouter);
app.use('/api/fridge', fridgeRouter);

app.get('/', (req, res) => {
  res.json({
    message: 'Little Fridge API',
    version: '1.0.0',
    endpoints: {
      auth: '/api/auth',
      foods: '/api/foods',
      fridge: '/api/fridge'
    }
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Add '0.0.0.0' here!
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Auth: http://localhost:${PORT}/api/auth`);
  console.log(`Foods: http://localhost:${PORT}/api/foods`);
  console.log(`Fridge: http://localhost:${PORT}/api/fridge`);
});

process.on('SIGINT', async () => {
  console.log('\nShutting down gracefully...');
  await prisma.$disconnect();
  process.exit(0);
});

module.exports = app;