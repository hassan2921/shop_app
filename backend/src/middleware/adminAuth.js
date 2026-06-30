const authMiddleware = require('./auth');

module.exports = (req, res, next) => {
  authMiddleware(req, res, () => {
    if (!req.user.isAdmin) {
      return res.status(403).json({ message: 'Admin access required' });
    }
    next();
  });
};
