const express = require('express');
const router = express.Router();
const { read, list,create,update,remove } = require('../Controller/Hospital');
router.get('/Hospital',list);
router.get('/Hospital/:hosId',read);
router.post('/Hospital',create);
router.delete('/Hospital/:hosId', remove);
module.exports = router;