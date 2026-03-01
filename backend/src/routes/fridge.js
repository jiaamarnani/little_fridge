const express = require('express');
const { PrismaClient } = require('@prisma/client');
const { requireAuth } = require('../middleware/auth');

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

// GET /my-fridges - Get all fridges for current user
router.get('/my-fridges', requireAuth, async (req, res) => {
  try {
    const userId = req.user.id;
    
    const userFridges = await prisma.UserFridge.findMany({
      where: { user_id: userId },
      include: {
        Fridge: true  // Include fridge details
      }
    });
    
    const fridges = userFridges.map(uf => ({
      fridge_id: uf.Fridge.fridge_id,
      group_name: uf.Fridge.group_name,
      invite_code: uf.Fridge.invite_code,
      created_at: uf.Fridge.created_at,
      joined_at: uf.joined_at
    }));
    
    res.json(fridges);
  } catch (error) {
    console.error('Error fetching user fridges:', error);
    res.status(500).json({ error: 'Failed to fetch fridges' });
  }
});

// POST /create - Create a new fridge group
router.post('/create', requireAuth, async (req, res) => {
  try {
    const { groupName } = req.body;
    const userId = req.user.id;  // From token

    if (!groupName) {
      return res.status(400).json({ error: 'Group name is required' });
    }

    // Generate unique invite code
    let inviteCode;
    let exists = true;
    while (exists) {
      inviteCode = generateInviteCode();
      const existing = await prisma.Fridge.findFirst({
        where: { invite_code: inviteCode }
      });
      exists = !!existing;
    }

    // Create fridge
    const fridge = await prisma.Fridge.create({
      data: {
        group_name: groupName,
        invite_code: inviteCode
      }
    });

    // Add creator as first member
    await prisma.UserFridge.create({
      data: {
        fridge_id: fridge.fridge_id,
        user_id: userId
      }
    });

    res.status(201).json({
      fridge_id: fridge.fridge_id,
      group_name: fridge.group_name,
      invite_code: fridge.invite_code
    });
  } catch (error) {
    console.error('Error creating fridge:', error);
    res.status(500).json({ error: 'Failed to create fridge group' });
  }
});

// POST /join - Join fridge with invite code
router.post('/join', requireAuth, async (req, res) => {
  try {
    const { inviteCode } = req.body;
    const userId = req.user.id;  // From token

    if (!inviteCode) {
      return res.status(400).json({ error: 'Invite code is required' });
    }

    // Find fridge by invite code
    const fridge = await prisma.Fridge.findFirst({
      where: { invite_code: inviteCode }
    });

    if (!fridge) {
      return res.status(404).json({ error: 'Invalid invite code' });
    }

    // Check if already a member
    const existingMember = await prisma.UserFridge.findFirst({
      where: {
        fridge_id: fridge.fridge_id,
        user_id: userId
      }
    });

    if (existingMember) {
      return res.status(400).json({ error: 'Already a member of this fridge' });
    }

    // Add user to fridge
    await prisma.UserFridge.create({
      data: {
        fridge_id: fridge.fridge_id,
        user_id: userId
      }
    });

    res.json({
      fridge_id: fridge.fridge_id,
      group_name: fridge.group_name,
      invite_code: fridge.invite_code
    });
  } catch (error) {
    console.error('Error joining fridge:', error);
    res.status(500).json({ error: 'Failed to join fridge group' });
  }
});

// GET /:fridgeId/items - Get all items in a fridge
router.get('/:fridgeId/items', requireAuth, async (req, res) => {
  try {
    const { fridgeId } = req.params;
    const userId = req.user.id;
    
    // Check if user has access to this fridge
    const hasAccess = await prisma.UserFridge.findFirst({
      where: {
        fridge_id: fridgeId,
        user_id: userId
      }
    });
    
    if (!hasAccess) {
      return res.status(403).json({ error: 'You do not have access to this fridge' });
    }
    
    // Get all items
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

// GET /:fridgeId/category/:category - Get items by category
router.get('/:fridgeId/category/:category', requireAuth, async (req, res) => {
  try {
    const { fridgeId, category } = req.params;
    const userId = req.user.id;
    
    // Check access
    const hasAccess = await prisma.UserFridge.findFirst({
      where: {
        fridge_id: fridgeId,
        user_id: userId
      }
    });
    
    if (!hasAccess) {
      return res.status(403).json({ error: 'You do not have access to this fridge' });
    }
    
    // Get items by category
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

// POST /:fridgeId/items - Add item to fridge
router.post('/:fridgeId/items', requireAuth, async (req, res) => {
  try {
    const { fridgeId } = req.params;
    const { foodName, quantity, expiresAt } = req.body;
    const userId = req.user.id;  // From token
    
    if (!foodName) {
      return res.status(400).json({ error: 'Food name is required' });
    }
    
    // Check access
    const hasAccess = await prisma.UserFridge.findFirst({
      where: {
        fridge_id: fridgeId,
        user_id: userId
      }
    });
    
    if (!hasAccess) {
      return res.status(403).json({ error: 'You do not have access to this fridge' });
    }
    
    // Verify food exists
    const foodExists = await prisma.Foods.findUnique({
      where: { food_name: foodName }
    });
    
    if (!foodExists) {
      return res.status(404).json({ error: 'Food not found in database' });
    }
    
    // Add item
    const item = await prisma.FridgeItems.create({
      data: {
        fridge_id: fridgeId,
        food_name: foodName,
        quantity: quantity || 1,
        added_by_user_id: userId,  // Automatically set from token
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

// PATCH /items/:itemId - Update item quantity
router.patch('/items/:itemId', requireAuth, async (req, res) => {
  try {
    const { itemId } = req.params;
    const { quantity } = req.body;
    const userId = req.user.id;
    
    if (quantity === undefined) {
      return res.status(400).json({ error: 'Quantity is required' });
    }
    
    // Get item
    const item = await prisma.FridgeItems.findUnique({
      where: { id: itemId }
    });
    
    if (!item) {
      return res.status(404).json({ error: 'Item not found' });
    }
    
    // Check access
    const hasAccess = await prisma.UserFridge.findFirst({
      where: {
        fridge_id: item.fridge_id,
        user_id: userId
      }
    });
    
    if (!hasAccess) {
      return res.status(403).json({ error: 'You do not have access to this fridge' });
    }
    
    // Update quantity
    const updatedItem = await prisma.FridgeItems.update({
      where: { id: itemId },
      data: { quantity },
      include: { foods: true }
    });
    
    res.json(updatedItem);
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: 'Failed to update item' });
  }
});

// DELETE /items/:itemId - Delete item from fridge
router.delete('/items/:itemId', requireAuth, async (req, res) => {
  try {
    const { itemId } = req.params;
    const userId = req.user.id;
    
    // Get item
    const item = await prisma.FridgeItems.findUnique({
      where: { id: itemId }
    });
    
    if (!item) {
      return res.status(404).json({ error: 'Item not found' });
    }
    
    // Check access
    const hasAccess = await prisma.UserFridge.findFirst({
      where: {
        fridge_id: item.fridge_id,
        user_id: userId
      }
    });
    
    if (!hasAccess) {
      return res.status(403).json({ error: 'You do not have access to this fridge' });
    }
    
    // Delete item
    await prisma.FridgeItems.delete({
      where: { id: itemId }
    });
    
    res.status(204).send();
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: 'Failed to delete item' });
  }
});

// Backend route for batch insert
router.post('/:fridgeId/items/batch', requireAuth, async (req, res) => {
  const { items } = req.body;  // Array of{foodName, quantity}
  
  await prisma.FridgeItems.createMany({
    data: items.map(item => ({
      fridge_id: fridgeId,
      food_name: item.foodName,
      quantity: item.quantity,
      added_by_user_id: userId
    }))
  });
});

module.exports = router;