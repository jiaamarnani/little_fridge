const supabase = require('../config/supabase');

async function requireAuth(req, res, next) {
  try {
    //get token from Authorization header
    const token = req.headers.authorization?.split('Bearer ')[1];
    
    if (!token) {
      return res.status(401).json({ error: 'Authentication required' });
    }
    
    //verify token with Supabase
    const { data: { user }, error } = await supabase.auth.getUser(token);
    
    if (error || !user) {
      return res.status(401).json({ error: 'Invalid token' });
    }
    
    //add user to request object so routes can access it
    req.user = user;
    next();  //continue to the route
  } catch (error) {
    console.error('Auth middleware error:', error);
    res.status(500).json({ error: 'Authentication failed' });
  }
}

module.exports = { requireAuth };