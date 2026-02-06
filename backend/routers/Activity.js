const express = require('express');
const router = express.Router();
const {activitypostlist,singleactivitypost,createactivitypost,updateactivitypost,removeactivitypost } = require('../Controller/Activity');
const { create } = require('../Controller/Hospital');
//ฝั่งเจ้าหน้าที่
router.get('/Activitypost',activitypostlist);
router.get('/Activitypost/:activitypostId',singleactivitypost);
router.post('/Activitypost',createactivitypost);
router.put('/Activitypost/:activitypostId',updateactivitypost);
router.delete('/Activitypost/:activitypostId', removeactivitypost);
//port ฝั่งนักศึกษา
const {activityportlist,singleactivityport,createactivityport,updateactivityport,removeactivityport,
    singleactivity,createactivity,updateactivity,removeactivity,followactivity} = require('../Controller/Activity');
router.get('/Activityport',activityportlist);
router.get('/Activityport/:activityportId',singleactivityport);
router.post('/Activityport',createactivityport);
router.put('/Activityport/:activityportId',updateactivityport);
router.delete('/Activityport/:activityportId', removeactivityport);
//กิจกรรมในport
router.get('/Activityport/:activityportId/:activityId',singleactivity);
router.post('/Activityport/:activityportId/createactivity',createactivity);
router.put('/Activityport/:activityportId/:activityId',updateactivity);
router.delete('/Activityport/:activityportId/:activityId', removeactivity);
router.post('/Activitypost/:activitypostId/follow',followactivity);
module.exports = router;
//เดียวต้องเพิ่มตรงเจ้าหน้าที่กดปุ่มอนุมัติไม่อนุมัติ