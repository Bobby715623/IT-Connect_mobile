const express = require('express');
const router = express.Router();
const { infowelfare, welfarelist,createwelfare,editwelfare,removewelfare,getScholarshipWelfare} = require('../Controller/Welfare');

router.get('/welfare/scholarship', getScholarshipWelfare);

router.get('/Welfare',welfarelist);
router.get('/Welfare/:welfareId',infowelfare);
router.post('/Welfare',createwelfare);
router.put('/Welfare/:welfareId',editwelfare);
router.delete('/Welfare/:welfareId', removewelfare);

module.exports = router;