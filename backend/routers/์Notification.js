const express = require('express');
const router = express.Router();
const { 
    createNotification, 
    getAllNotification, 
    getMyNotification, 
    getNotificationById,
    readNotification,
    readallNotification,
    updateNotification,
    deleteNotification
} = require('../Controller/Notification');
router.post('/Notification', createNotification);
router.get('/Notification', getAllNotification);
router.get('/Notification/user/:userId', getMyNotification);
router.get('/Notification/:notificationId', getNotificationById);
router.put('/Notification/:notificationId/read', readNotification);
router.put('/Notification/user/:userId/readAll', readallNotification);
router.put('/Notification/user/:notificatioId', updateNotification);
router.delete('/Notification/:notificationId', deleteNotification);
module.exports = router;