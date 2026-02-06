const express = require('express');
const router = express.Router();
const { 
    createrole, 
    getrole,
    getuserrole,
    addroletouser,
    delrolefromuser,
    editrole,
    deleterole, 
} = require('../Controller/Role');
router.post('/Role', createrole);
router.get('/Role', getrole);
router.get('/Role/:userId', getuserrole);
router.post('/Role/:userId/:roleId', addroletouser);
router.delete('/Role/:userId/:roleId', delrolefromuser);
router.put('/Role/:roleId', editrole);
router.delete('/Role/:roleId', deleterole);
module.exports = router;