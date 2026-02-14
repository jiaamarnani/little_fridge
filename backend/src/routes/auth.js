const express = require('express');
const supabase = require('../config/supabase');
const { PrismaClient } = require('@prisma/client');

const router = express.Router();
const prisma = new PrismaClient();

//POST create Account
router.post('/signup', async (req, res) => {
  try {
    const { email, password, name } = req.body;
    
    if (!email || !password) {
      return res.status(400).json({ 
        error: 'Email and password are required' 
      });
    }
    
    //make user in Supabase Auth
    const { data, error } = await supabase.auth.createAccount({
      email: email,
      password: password,
      options: {
        data: {
          name: name
        }
      }
    });
    
    if (error) {
      return res.status(400).json({ error: error.message });
    }
    
    //make user in actual database users table
    try {
      await prisma.users.create({
        data: {
          user_id: data.user.id,      //supabase auth user ID
          user_email: email,
          user_name: name || null
        }
      });
    } catch (dbError) {
      console.error('Database user creation failed:', dbError);
      //user was tried created in auth but database failed
 //     try {
 //       prisma.users.delete({
 //         data: {
 //         user_id: data.user.id
 //         }
 //       })
 //     } catch (error) {
        //??
 //       }
      return res.status(500).json({
        error: 'Account created but database sync failed'
      });
    }
    
    res.status(201).json({
      message: 'Account created successfully',
      user: {
        id: data.user.id,
        email: data.user.email,
        name: name
      },
      session: data.session
    });
  } catch (error) {
    console.error('Signup error:', error);
    res.status(500).json({ error: 'Failed to create account' });
  }
});

//POST signin
router.post('/signin', async (req, res) => {
  try {
    const { email, password } = req.body;
    
    if (!email || !password) {
      return res.status(400).json({ 
        error: 'Email and password are required' 
      });
    }
    
    const { data, error } = await supabase.auth.signInWithPassword({
      email: email,
      password: password
    });
    
    if (error) {
      return res.status(401).json({ error: error.message });
    }
    
    res.json({
      message: 'Signed in successfully',
      user: {
        id: data.user.id,
        email: data.user.email,
        name: data.user.user_metadata.name
      },
      session: data.session
    });
  } catch (error) {
    console.error('Signin error:', error);
    res.status(500).json({ error: 'Failed to sign in' });
  }
});

//POST signout
router.post('/signout', async (req, res) => {
  try {
    const { error } = await supabase.auth.signOut();
    
    if (error) {
      return res.status(400).json({ error: error.message });
    }
    
    res.json({ message: 'Signed out successfully' });
  } catch (error) {
    console.error('Signout error:', error);
    res.status(500).json({ error: 'Failed to sign out' });
  }
});

// GET current user
router.get('/me', async (req, res) => {
  try {
    const token = req.headers.authorization?.split('Bearer ')[1];
    
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }
    
    const { data: { user }, error } = await supabase.auth.getUser(token);
    
    if (error || !user) {
      return res.status(401).json({ error: 'Invalid token' });
    }
    
    //user from db
    const dbUser = await prisma.users.findUnique({
      where: { user_id: user.id }
    });
    
    res.json({
      user: {
        id: user.id,
        email: user.email,
        name: dbUser?.user_name || user.user_metadata.name,
        created_at: user.created_at
      }
    });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ error: 'Failed to get user' });
  }
});

module.exports = router;