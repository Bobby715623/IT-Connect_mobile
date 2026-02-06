const express = require('express');
const router = express.Router();
const {createSubject,getAllSubjects,getSubjectById,updateSubject,deleteSubject,createSection,
    getSectionById, 
    updateSection, 
    deleteSection,
    enrollStudent, 
    getStudentSchedule, 
    getStudentsInSec, 
    withdraw
} = require('../Controller/Subject');
router.post('/Subject', createSubject);
router.get('/Subject', getAllSubjects);
router.get('/Subject/:subjectId', getSubjectById);
router.put('/Subject/:subjectId', updateSubject);
router.delete('/Subject/:subjectId', deleteSubject);
router.post('/SubjectSec', createSection);
router.get('/SubjectSec/:secId', getSectionById);
router.put('/SubjectSec/:secId', updateSection);
router.delete('/SubjectSec/:secId', deleteSection);
router.post('/Enroll', enrollStudent);
router.get('/Enroll/User/:userId', getStudentSchedule);
router.get('/Enroll/Section/:secId', getStudentsInSec);
router.delete('/Enroll/:enrollId', withdraw);
module.exports = router;