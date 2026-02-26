const express = require('express');
const router = express.Router();
const auth = require('../middlewares/auth.middleware');
const upload = require('../middlewares/upload.middleware');

const { 
    listScholarships,getScholarship,createScholarship,updateScholarship,removeScholarship,applyScholarship,myHistory,updateApplicationStatus,viewapplication,approveScholarship,viewscholarshipactivityport,viewsinglescholarshipactivityport, removeApplication 
} = require('../Controller/Scholarship');
router.get('/scholarship', listScholarships);
router.get('/scholarship/:id', getScholarship);
router.post('/scholarship', createScholarship);
router.put('/scholarship/:id', updateScholarship);
router.delete('/scholarship/:id', removeScholarship);
router.put('/scholarship/application/:applicationId/:status', updateApplicationStatus);
router.delete('/scholarship/application/:applicationId', removeApplication);
router.post('/scholarship/apply', auth, upload.array('files'), applyScholarship);
router.get('/scholarship/history/:userId', auth, myHistory);
router.get('/scholarship/application/:applicationid', viewapplication);
router.put('/scholarship/approve/:applicationId', approveScholarship);
router.get('/scholarship/:scholarshipId/activityport', viewscholarshipactivityport);
router.get('/scholarship/activityport/:activityportId', viewsinglescholarshipactivityport);
module.exports = router;