const express = require('express');
const { PrismaClient } = require('@prisma/client');

const router = express.Router();
const prisma = new PrismaClient();

//GET all foods
router.get('/', async (req, res) => {
  try {
    const foods = await prisma.foods.findMany({
      orderBy: { food_name: 'asc' }
    });
    res.json(foods);
  } catch (error) {
    console.error('Error fetching foods:', error);
    res.status(500).json({ error: 'Failed to fetch foods' });
  }
});

//GET foods by category
router.get('/category/:category', async (req, res) => {
  try {
    const { category } = req.params;
    const foods = await prisma.foods.findMany({
      where: { food_category: category },
      orderBy: { food_name: 'asc' }
    });
    res.json(foods);
  } catch (error) {
    console.error('Error fetching foods:', error);
    res.status(500).json({ error: 'Failed to fetch foods' });
  }
});

//GET single food by name
router.get('/:name', async (req, res) => {
  try {
    const { name } = req.params;
    const food = await prisma.foods.findUnique({
      where: { food_name: name }
    });
    
    if (!food) {
      return res.status(404).json({ error: 'Food not found' });
    }
    
    res.json(food);
  } catch (error) {
    console.error('Error fetching food:', error);
    res.status(500).json({ error: 'Failed to fetch food' });
  }
});

module.exports = router;