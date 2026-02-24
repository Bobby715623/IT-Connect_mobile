const prisma = require('../prisma/prisma');
exports.createPersonalEvent = async (req, res) => {
    try {
        const { Title, Description, Deadline, Notify, NotifyDatetime, UserID } = req.body;

        const newEvent = await prisma.personalEvent.create({
            data: {
                Title,
                Description,
                Deadline: Deadline ? new Date(Deadline) : null,
                Notify: Notify || false,
                NotifyDatetime: NotifyDatetime ? new Date(NotifyDatetime) : null,
                UserID: Number(UserID)
            }
        });

        res.status(201).json({ message: "บันทึกกิจกรรมสำเร็จ", data: newEvent });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.getEventsByUserId = async (req, res) => {
    try {
        const { userId } = req.params;
        const events = await prisma.personalEvent.findMany({
            where: { UserID: Number(userId) },
            orderBy: { Deadline: 'asc' }
        });
        res.status(200).json(events);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
exports.getEventById = async (req, res) => {
    try {
        const { eventId } = req.params;
        const event = await prisma.personalEvent.findUnique({
            where: { PersonalEventID: Number(eventId) }
        });

        if (!event) return res.status(404).json({ message: "ไม่พบกิจกรรมนี้" });
        res.status(200).json(event);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
exports.updatePersonalEvent = async (req, res) => {
    try {
        const { eventId } = req.params;
        const { Title, Description, Deadline, Notify, NotifyDatetime } = req.body;

        const updatedEvent = await prisma.personalEvent.update({
            where: { PersonalEventID: Number(eventId) },
            data: {
                Title,
                Description,
                Deadline: Deadline ? new Date(Deadline) : undefined,
                Notify,
                NotifyDatetime: NotifyDatetime ? new Date(NotifyDatetime) : undefined,
            }
        });

        res.status(200).json({ message: "อัปเดตข้อมูลสำเร็จ", data: updatedEvent });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
exports.deletePersonalEvent = async (req, res) => {
    try {
        const { eventId } = req.params;

        console.log("Deleting ID:", eventId);

        const deleted = await prisma.personalEvent.delete({
            where: { PersonalEventID: Number(eventId) }
        });

        res.status(200).json({ message: "ลบกิจกรรมสำเร็จ", data: deleted });

    } catch (error) {
        console.error("DELETE ERROR:", error);
        res.status(500).json({ error: error.message });
    }
};
//แก้แล้ว