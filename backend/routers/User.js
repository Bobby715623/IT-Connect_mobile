const express = require('express');
const router = express.Router();
const { read, list,create,update,remove,login,googleLogin } = require('../Controller/User');
router.get('/User',list);
router.get('/User/:userId',read);
router.post('/User/',create);
router.put('/User/:userId',update);
router.delete('/User/:userId', remove);
router.post('/login', login);
router.post('/google', googleLogin);//มอสเพิ่ม
module.exports = router;