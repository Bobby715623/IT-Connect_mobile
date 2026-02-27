const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');

const {
  activitypostlist,
  singleactivitypost,
  createactivitypost,
  updateactivitypost,
  removeactivitypost,
  activityportlist,
  singleactivityport,
  createactivityport,
  updateactivityport,
  removeactivityport,
  singleactivity,
  createactivity,
  updateactivity,
  removeactivity,
  followactivity,
  getFollowedActivities,
  activityportByUser,
  uploadEvidence,
  removeEvidence,
  submitActivityFromPost  
} = require('../Controller/Activity');


// =================== MULTER ===================

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});

const upload = multer({ storage: storage });


// =================== ACTIVITY POST =================== ฝั่งเจ้าหน้าที่

router.get('/Activitypost', activitypostlist);
router.get('/Activitypost/:activitypostId', singleactivitypost);
router.post('/Activitypost', createactivitypost);
router.put('/Activitypost/:activitypostId', updateactivitypost);
router.delete('/Activitypost/:activitypostId', removeactivitypost);
router.post('/Activitypost/follow/:activitypostId', followactivity);
router.post(
  '/Activitypost/:activitypostId/submit',
  upload.array('images'),
  submitActivityFromPost
);
router.get("/Activitypost/follow/user/:userId", getFollowedActivities);


// =================== ACTIVITY PORT =================== 

router.get('/Activityport', activityportlist);
router.get('/Activityport/user/:userId', activityportByUser);
router.get('/Activityport/:activityportId', singleactivityport);
router.post('/Activityport', createactivityport);
router.put('/Activityport/:activityportId', updateactivityport);
router.delete('/Activityport/:activityportId', removeactivityport);


// =================== ACTIVITY (ใน PORT) =================== 

// 🔥 แยก path ให้ชัดเจน
router.get('/Activity/:activityId', singleactivity); //แก้อันนี้เพราะไม่งั้นมันจะเรียกไม่ได้
router.post('/Activityport/:activityportId/createactivity', createactivity);
router.put('/Activity/:activityId', updateactivity);
router.delete('/Activity/:activityId', removeactivity);


// =================== UPLOAD EVIDENCE ===================

router.post(
  '/Activity/:activityId/evidence',
  upload.array('images'),
  uploadEvidence
);
router.delete('/evidence/:evidenceId', removeEvidence);

module.exports = router;


