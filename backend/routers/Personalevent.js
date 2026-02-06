const express = require('express');
const router = express.Router();
const { 
    createPersonalEvent, 
    getEventsByUserId, 
    getEventById, 
    updatePersonalEvent, 
    deletePersonalEvent 
} = require('../Controller/Personalevent');
router.post('/PersonalEvent', createPersonalEvent);
router.get('/PersonalEvent/User/:userId', getEventsByUserId);
router.get('/PersonalEvent/:eventId', getEventById);
router.put('/PersonalEvent/:eventId', updatePersonalEvent);
router.delete('/PersonalEvent/:eventId', deletePersonalEvent);
module.exports = router;