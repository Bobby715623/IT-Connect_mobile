const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
//------------เพิ่มไว้เก็บรูป-------------//
const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, 'uploads/');
    },
    filename: function (req, file, cb) {
        cb(null, Date.now() + path.extname(file.originalname));
    }
});

const upload = multer({ storage: storage });
//------------จบเพิ่มไว้เก็บรูป-------------// มอสเพิ่ม

exports.activitypostlist = async (req, res) => {
    try {
        const activities = await prisma.activityPost.findMany({
            include: {
                Officer: true,  
            },
            orderBy: {
                ActivityPostID: 'desc'
            }
        });
        res.send(activities);
    } catch (err) {
        console.log(err);
        res.status(500).send('Server Error');
    }
};
exports.singleactivitypost = async (req, res) => {
    try {
        const { activitypostId } = req.params;
        const activity = await prisma.activityPost.findUnique({
            where: {
                ActivityPostID: Number(activitypostId)
            },
            include: {
                Officer: true
            }
        });

        if (!activity) {
            return res.status(404).send('Activity not found');
        }

        res.send(activity);
    } catch (err) {
        console.log(err);
        res.status(500).send('Server Error');
    }
};
exports.createactivitypost = async (req, res) => {
    try {
        const { 
            Title, Description, HourofActivity, Location, DatetimeofActivity, Picture, OfficerID , 
        } = req.body;

        if (!OfficerID) return res.status(400).send('OfficerID is required');
        const newActivity = await prisma.activityPost.create({
            data: {
                Title: Title,
                Description: Description,
                Location: Location,
                HourofActivity: HourofActivity ? Number(HourofActivity) : null,
                DatetimeofActivity: DatetimeofActivity ? new Date(DatetimeofActivity) : null,
                Picture: Picture || null, //มอสเพิ่มมา
                Officer: {
                    connect: {
                        OfficerID: Number(OfficerID)
                    }
                }
            }
        });
        res.send(newActivity);
    } catch (err) {
        console.log(err);
        res.status(500).send('Server Error: ' + err.message);
    }
};
exports.updateactivitypost = async (req, res) => {
    try {
        const { activitypostId } = req.params;
        const { 
            Title, Description, HourofActivity, Location, DatetimeofActivity 
        } = req.body;

        const updatedActivity = await prisma.activityPost.update({
            where: {
                ActivityPostID: Number(activitypostId)
            },
            data: {
                Title: Title,
                Description: Description,
                Location: Location,
                HourofActivity: HourofActivity ? Number(HourofActivity) : undefined,
                DatetimeofActivity: DatetimeofActivity ? new Date(DatetimeofActivity) : undefined
            }
        });
        res.send(updatedActivity);
    } catch (err) {
        console.log(err);
        res.status(500).send('Server Error: ' + err.message);
    }
};
exports.removeactivitypost = async (req, res) => {
    try {
        const { activitypostId } = req.params;
        
        const deletedActivity = await prisma.activityPost.delete({
            where: {
                ActivityPostID: Number(activitypostId)
            }
        });
        res.send(deletedActivity);
    } catch (err) {
        console.log(err);
        res.status(500).send('Server Error: ' + err.message);
    }
};
exports.activityportlist = async (req, res) => {
    try {
        const ports = await prisma.activityPort.findMany({
            include: { Activity: true }
        });
        res.json(ports);
    } catch (err) {
        console.log(err);
        res.status(500).json({ message: "Server Error" });
    }
};

exports.singleactivityport = async (req, res) => {
    try {
        const { activityportId } = req.params;
        const port = await prisma.activityPort.findUnique({
            where: { ActivityPortID: Number(activityportId) },
            include: { Activity: true }
        });
        res.json(port);
    } catch (err) {
        console.log(err);
        res.status(500).json({ message: "Server Error" });
    }
};

//มอสเพิ่มนะ เอาดึง port ของแต่ละ user
exports.activityportByUser = async (req, res) => {
    try {
        const { userId } = req.params;

        const ports = await prisma.activityPort.findMany({
            where: {
                UserID: Number(userId)
            },
            include: {
                Activity: true
            }
        });

        res.json(ports);
    } catch (err) {
        console.log(err);
        res.status(500).json({ message: "Server Error" });
    }
};


exports.createactivityport = async (req, res) => {
    try {
        const { Portname, HourNeed, Type, CreateDate, EndDate, UserID } = req.body;
        
        const newPort = await prisma.activityPort.create({
            data: {
                Portname,
                HourNeed: Number(HourNeed),
                Type : 'Custom',
                CreateDate: new Date(CreateDate),
                EndDate: new Date(EndDate),
                UserID: Number(UserID),
                status: 'active',
            }
        });
        res.json(newPort);
    } catch (err) {
        console.log(err);
        res.status(500).json({ message: "Server Error" });
    }
};

exports.updateactivityport = async (req, res) => {
    try {
        const { activityportId } = req.params;
        const { Portname, HourNeed, Type, EndDate } = req.body;

        const updatedPort = await prisma.activityPort.update({
            where: { ActivityPortID: Number(activityportId) },
            data: {
                Portname,
                HourNeed: Number(HourNeed),
                Type,
                EndDate: new Date(EndDate)
            }
        });
        res.json(updatedPort);
    } catch (err) {
        console.log(err);
        res.status(500).json({ message: "Server Error" });
    }
};
exports.removeactivityport = async (req, res) => {
    try {
        const { activityportId } = req.params;
        await prisma.activityPort.delete({
            where: { ActivityPortID: Number(activityportId) }
        });
        res.send("Activity Port Deleted");
    } catch (err) {
        console.log(err);
        res.status(500).json({ message: "Server Error" });
    }
};
exports.singleactivity = async (req, res) => {
    try {
        const { activityId } = req.params;
        const activity = await prisma.activity.findUnique({
            where: { ActivityID: Number(activityId) },
            include: { ActivityEvidence: true }
        });
        res.json(activity);
    } catch (err) {
        console.log(err);
        res.status(500).json({ message: "Server Error" });
    }
};

exports.createactivity = async (req, res) => {
    try {
        const { activityportId } = req.params;
        const { ActivityName, Description, HourofActivity, Location, DatetimeofActivity, Status, Comment } = req.body;

        const newActivity = await prisma.activity.create({
            data: {
                ActivityName,
                Description,
                HourofActivity: Number(HourofActivity),
                Location,
                DatetimeofActivity: new Date(DatetimeofActivity),
                Status,
                Comment,
                ActivityPortID: Number(activityportId)
            }
        });
        res.json(newActivity);
    } catch (err) {
        console.log(err);
        res.status(500).json({ message: "Server Error" });
    }
};

exports.updateactivity = async (req, res) => {
    try {
        const { activityId } = req.params;
        const { ActivityName, Description, HourofActivity, Location, DatetimeofActivity, Status } = req.body;

        const updatedActivity = await prisma.activity.update({
            where: { ActivityID: Number(activityId) },
            data: {
                ActivityName,
                Description,
                HourofActivity: Number(HourofActivity),
                Location,
                DatetimeofActivity: new Date(DatetimeofActivity),
                Status
            }
        });
        res.json(updatedActivity);
    } catch (err) {
        console.log(err);
        res.status(500).json({ message: "Server Error" });
    }
};
exports.removeactivity = async (req, res) => {
    try {
        const { activityId } = req.params;
        await prisma.activity.delete({
            where: { ActivityID: Number(activityId) }
        });
        res.send("Activity Deleted");
    } catch (err) {
        console.log(err);
        res.status(500).json({ message: "Server Error" });
    }
};
exports.followactivity = async (req, res) => {
    try {
        const { activitypostId } = req.params;
        const { UserID } = req.body;
        const existingFollow = await prisma.follow_ActivityPost.findFirst({
            where: {
                ActivityPostID: Number(activitypostId),
                UserID: Number(UserID)
            }
        });
        if (existingFollow) {
            return res.status(400).json({ message: "You already followed this activity" });
        }

        const newFollow = await prisma.follow_ActivityPost.create({
            data: {
                ActivityPostID: Number(activitypostId),
                UserID: Number(UserID)
            }
        });
        res.json(newFollow);
    } catch (err) {
        console.log(err);
        res.status(500).json({ message: "Server Error" });
    }
};

//------มอสเพิ่ม ไว้เก็บรูป--------//
exports.uploadEvidence = async (req, res) => {
    try {
        const { activityId } = req.params;

        if (!req.files || req.files.length === 0) {
            return res.status(400).json({ message: "No files uploaded" });
        }

        const evidenceData = req.files.map(file => ({
            Picture: file.filename,
            ActivityID: Number(activityId)
        }));

        await prisma.activityEvidence.createMany({
            data: evidenceData
        });

        res.json({ message: "Evidence uploaded successfully" });
    } catch (err) {
        console.log(err);
        res.status(500).json({ message: "Server Error" });
    }
};