const express = require('express');
const router = express.Router();
const { infowelfare, welfarelist,createwelfare,editwelfare,removewelfare,getWelfareByType } = require('../Controller/Welfare');

router.get('/type/:type', getWelfareByType);

router.get('/Welfare',welfarelist);
router.get('/Welfare/:welfareId',infowelfare);
router.post('/Welfare',createwelfare);
router.put('/Welfare/:welfareId',editwelfare);
router.delete('/Welfare/:welfareId', removewelfare);

module.exports = router;