const express = require('express');
const { PrismaClient } = require('@prisma/client');

const router = express.Router();
const prisma = new PrismaClient();

//GET all items in a fridge
router.get('/:fridgeId/items', async (req, res) => {
  try {
    const { fridgeId } = req.params;
    
    const items = await prisma.fridge_items.findMany({
      where: { fridge_id: fridgeId },
      include: {
        foods: true
      },
      orderBy: { added_at: 'desc' }
    });
    
    res.json(items);
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: 'Failed to fetch fridge items' });
  }
});

//GET items in fridge by category
router.get('/:fridgeId/category/:category', async (req, res) => {
  try {
    const { fridgeId, category } = req.params;
    
    const items = await prisma.fridge_items.findMany({
      where: {
        fridge_id: fridgeId,
        foods: {
          food_category: category
        }
      },
      include: {
        foods: true
      },
      orderBy: { added_at: 'desc' }
    });
    
    res.json(items);
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: 'Failed to fetch items' });
  }
});

//POST add item to fridge
router.post('/:fridgeId/items', async (req, res) => {
  try {
    const { fridgeId } = req.params;
    const { foodName, quantity, addedByUserId, expiresAt } = req.body;
    
    const item = await prisma.fridge_items.create({
      data: {
        fridge_id: fridgeId,
        food_name: foodName,
        quantity: quantity || 1,
        added_by_user_id: addedByUserId,
        expires_at: expiresAt ? new Date(expiresAt) : null
      },
      include: {
        foods: true
      }
    });
    
    res.status(201).json(item);
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: 'Failed to add item' });
  }
});

//DELETE item from fridge
router.delete('/items/:itemId', async (req, res) => {
  try {
    const { itemId } = req.params;
    
    await prisma.fridge_items.delete({
      where: { id: itemId }
    });
    
    res.status(204).send();
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: 'Failed to delete item' });
  }
});

module.exports = router;