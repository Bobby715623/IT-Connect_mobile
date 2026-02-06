const prisma = require('../prisma/prisma');
exports.createNotification = async (req, res) => {
    try {
        const { 
            Title, Message, NotificationType, NotificationTargetType, 
            TargetID, ActionURL, NotificationTime, UserID 
        } = req.body;

        const newNotification = await prisma.notification.create({
            data: {
                Title,
                Message,
                NotificationType,
                NotificationTargetType,
                TargetID,
                ActionURL,
                NotificationTime: new Date(NotificationTime),
                UserID: Number(UserID),
                IsRead: false,
                IsSent: false
            }
        });

        res.status(201).json(newNotification);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
exports.getAllNotification = async (req, res) => {
    try {
        const notifications = await prisma.notification.findMany({
            orderBy: { NotificationID: 'desc' }
        });
        res.status(200).json(notifications);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
exports.getNotificationById = async (req, res) => {
    try {
        const { notificationId } = req.params;
        const notification = await prisma.notification.findUnique({
            where: { NotificationID: Number(notificationId) }
        });

        if (!notification) {
            return res.status(404).json({ message: "ไม่พบแจ้งเตือน" });
        }

        res.status(200).json(notification);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
exports.updateNotification = async (req, res) => {
    try {
        const { notificatioId } = req.params;
        const dataToUpdate = req.body;

        const updatedNotification = await prisma.notification.update({
            where: { NotificationID: Number(notificatioId) },
            data: dataToUpdate
        });

        res.status(200).json(updatedNotification);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
exports.readNotification = async (req, res) => {
    try {
        const { notificationId } = req.params;
        const updatedNotification = await prisma.notification.update({
            where: { NotificationID: Number(notificationId) },
            data: { IsRead: true }
        });
        res.status(200).json(updatedNotification);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
exports.readallNotification = async (req, res) => {
    try {
        const { userId } = req.params;
        const updatedNotification = await prisma.notification.updateMany({
            where: { UserID: Number(userId),
                IsRead: false
             },
            data: { IsRead: true }
        });
        res.status(200).json(updatedNotification);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
exports.deleteNotification = async (req, res) => {
    try {
        const { id } = req.params;
        await prisma.notification.delete({
            where: { NotificationID: Number(id) }
        });
        res.status(200).json({ message: "ลบสำเร็จ" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
exports.getMyNotification = async (req, res) => {
    try {
        const { userId } = req.params;
        const notifications = await prisma.notification.findMany({
            where: { 
                UserID: Number(userId),
            },
            orderBy: { NotificationTime: 'desc' }
        });
        res.status(200).json(notifications);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};