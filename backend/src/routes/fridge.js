const express = require('express');
const { PrismaClient } = require('@prisma/client');

const router = express.Router();
const prisma = new PrismaClient();

// Helper: generate a 6-char invite code
function generateInviteCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let code = '';
  for (let i = 0; i < 6; i++) {
    code += chars[Math.floor(Math.random() * chars.length)];
  }
  return code;
}

// POST /create — Create a new fridge group
router.post('/create', async (req, res) => {
  try {
    const { groupName, userId } = req.body;

    let inviteCode;
    let exists = true;
    while (exists) {
      inviteCode = generateInviteCode();
      const existing = await prisma.Fridge.findFirst({
        where: { invite_code: inviteCode }
      });
      exists = !!existing;
    }

    const fridge = await prisma.Fridge.create({
      data: {
        group_name: groupName,
        invite_code: inviteCode
      }
    });

    if (userId) {
      await prisma.UserFridge.create({
        data: {
          fridge_id: fridge.fridge_id,
          user_id: BigInt(userId)
        }
      });
    }

    res.status(201).json({
      fridge_id: fridge.fridge_id.toString(),
      group_name: fridge.group_name,
      invite_code: fridge.invite_code
    });
  } catch (error) {
    console.error('Error creating fridge:', error);
    res.status(500).json({ error: 'Failed to create fridge group' });
  }
});

// POST /join — Join with invite code
router.post('/join', async (req, res) => {
  try {
    const { inviteCode, userId } = req.body;

    const fridge = await prisma.Fridge.findFirst({
      where: { invite_code: inviteCode }
    });

    if (!fridge) {
      return res.status(404).json({ error: 'Invalid invite code' });
    }

    const existingMember = await prisma.UserFridge.findFirst({
      where: {
        fridge_id: fridge.fridge_id,
        user_id: BigInt(userId)
      }
    });

    if (!existingMember) {
      await prisma.UserFridge.create({
        data: {
          fridge_id: fridge.fridge_id,
          user_id: BigInt(userId)
        }
      });
    }

    res.json({
      fridge_id: fridge.fridge_id.toString(),
      group_name: fridge.group_name,
      invite_code: fridge.invite_code
    });
  } catch (error) {
    console.error('Error joining fridge:', error);
    res.status(500).json({ error: 'Failed to join fridge group' });
  }
});

//GET all items in a fridge
router.get('/:fridgeId/items', async (req, res) => {
  try {
    const { fridgeId } = req.params;
    
    const items = await prisma.FridgeItems.findMany({
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
    
    const items = await prisma.FridgeItems.findMany({
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
    
    const item = await prisma.FridgeItems.create({
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
    
    await prisma.FridgeItems.delete({
      where: { id: itemId }
    });
    
    res.status(204).send();
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: 'Failed to delete item' });
  }
});



module.exports = router;