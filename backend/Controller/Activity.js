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
            include: { 
                Activity: {
                    include: {
                        RelatedPost: true   // 🔥 เพิ่มอันนี้
                    }
                }
            }
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
            include: { 
                ActivityEvidence: true,
                RelatedPost: true   // 🔥 เพิ่มอันนี้
            }
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

    const activity = await prisma.activity.findUnique({
      where: { ActivityID: Number(activityId) }
    });

    if (!activity) {
      return res.status(404).json({ message: "Activity not found" });
    }

    // ✅ เช็ค enum ให้ตรงกับ Prisma
    if (activity.Status !== "waitforprocess") {
      return res.status(400).json({
        message: "Cannot delete activity after approval"
      });
    }

    await prisma.activity.delete({
      where: { ActivityID: Number(activityId) }
    });

    res.json({ message: "Activity Deleted Successfully" });

  } catch (err) {
    console.log(err);
    res.status(500).json({ message: "Server Error" });
  }
};
//มอสแก้ remove นะ

exports.followactivity = async (req, res) => {
  try {
    const { activitypostId } = req.params;
    const { UserID } = req.body;

    const activityId = Number(activitypostId);
    const userId = Number(UserID);

    // 🔎 1. เช็คว่ามี follow อยู่ไหม
    const existingFollow = await prisma.follow_ActivityPost.findFirst({
      where: {
        ActivityPostID: activityId,
        UserID: userId
      }
    });

    
    // 🟥 UNFOLLOW
    if (existingFollow) {

  // ลบ follow แบบชัวร์ ๆ
  await prisma.follow_ActivityPost.deleteMany({
    where: {
      UserID: userId,
      ActivityPostID: activityId
    }
  });

  // ลบ personal event ด้วย
  await prisma.personalEvent.deleteMany({
    where: {
      UserID: userId,
      ActivityPostID: activityId
    }
  });

  return res.json({ followed: false });
}

    // 🟢 ถ้าไม่มี → FOLLOW

    const activityPost = await prisma.activityPost.findUnique({
      where: {
        ActivityPostID: activityId
      }
    });

    if (!activityPost) {
      return res.status(404).json({ message: "Activity not found" });
    }

    // สร้าง follow
    await prisma.follow_ActivityPost.create({
      data: {
        ActivityPostID: activityId,
        UserID: userId
      }
    });

    // สร้าง personal event
    await prisma.personalEvent.create({
      data: {
        Title: activityPost.Title,
        Description: activityPost.Description,
        Deadline: activityPost.DatetimeofActivity,
        Notify: true,
        UserID: userId,
        ActivityPostID: activityId
      }
    });

    return res.json({ followed: true });

  } catch (err) {
    console.log(err);
    res.status(500).json({ message: "Server Error" });
  }
};

exports.getFollowedActivities = async (req, res) => {
  try {
    const { userId } = req.params;

    const follows = await prisma.follow_ActivityPost.findMany({
      where: {
        UserID: Number(userId)
      },
      select: {
        ActivityPostID: true
      }
    });

    res.json(follows);
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

exports.removeEvidence = async (req, res) => {
  try {
    const { evidenceId } = req.params;

    const evidence = await prisma.activityEvidence.findUnique({
      where: { EvidenceID: Number(evidenceId) }
    });

    if (!evidence) {
      return res.status(404).json({ message: "Evidence not found" });
    }

    // 🔥 ลบ record จาก DB ก่อน
    await prisma.activityEvidence.delete({
      where: { EvidenceID: Number(evidenceId) }
    });

    res.json({ message: "Evidence deleted successfully" });

  } catch (err) {
    console.log(err);
    res.status(500).json({ message: "Server Error" });
  }
};

exports.submitActivityFromPost = async (req, res) => {
    try {
        const { activitypostId } = req.params;
        const { UserID, Description } = req.body;

        // 1. ✅ แก้ไข: ตรวจสอบ req.files (มี s) แทน req.file
        if (!req.files || req.files.length === 0) {
            return res.status(400).json({ message: "กรุณาแนบรูปภาพหลักฐานกิจกรรม" });
        }

        // 2. ดึงข้อมูล "ต้นฉบับ" จากโพสต์ของเจ้าหน้าที่
        const sourcePost = await prisma.activityPost.findUnique({
            where: { ActivityPostID: Number(activitypostId) },
            include: { Officer: { include: { User: true } } }
        });

        if (!sourcePost) return res.status(404).send('ไม่พบโพสต์กิจกรรมต้นทาง');

        // 3. หา "สมุดพก (ActivityPort)" ของนักเรียนที่ยัง Active อยู่
        const activePort = await prisma.activityPort.findFirst({
            where: {
                UserID: Number(UserID),
                OR: [{ status: 'active' }, { EndDate: { gte: new Date() } }]
            },
            orderBy: { CreateDate: 'desc' }
        });

        if (!activePort) return res.status(400).json({ message: "ไม่พบ Activity Port ที่ใช้งานได้" });

        // 4. เช็คว่าเคยส่งงานของโพสต์นี้ไปหรือยัง (กันส่งซ้ำ)
        const existingSubmission = await prisma.activity.findFirst({
            where: {
                ActivityPortID: activePort.ActivityPortID,
                RelatedPostID: Number(activitypostId)
            }
        });

        if (existingSubmission) return res.status(400).json({ message: "คุณได้ส่งข้อมูลกิจกรรมนี้ไปแล้ว" });

        // ✅ เตรียมข้อมูลรูปภาพทั้งหมด (Map จาก req.files)
        const evidenceData = req.files.map((file) => ({
            Picture: file.filename
        }));
        // 5. ✨ สร้าง Activity ใหม่ โดย "Copy" ข้อมูลจาก sourcePost
        const newActivity = await prisma.activity.create({
            data: {
                // ก๊อปปี้ข้อมูลจากโพสต์เจ้าหน้าที่ (เชื่อถือได้กว่าให้เด็กกรอกเอง)
                ActivityName: sourcePost.Title, 
                Description: Description || sourcePost.Description, // ถ้าเด็กไม่พิมอะไรมา ใช้ Description เดิมของโพสต์
                HourofActivity: sourcePost.HourofActivity,
                Location: sourcePost.Location,
                DatetimeofActivity: sourcePost.DatetimeofActivity,
                
                Status: 'waitforprocess', // สถานะเริ่มต้น: รอตรวจ
                
                // ✅ การเชื่อมโยง (Relations)
                ActivityPort: { connect: { ActivityPortID: activePort.ActivityPortID } }, // ยัดใส่พอร์ตนักเรียน
                RelatedPost: { connect: { ActivityPostID: Number(activitypostId) } },     // 🔗 ลิงก์กลับไปหาโพสต์ต้นทาง (สำคัญ!)

                // ✅ แนบรูปหลักฐาน
                ActivityEvidence: {
                    create: evidenceData
                }
            },
            include: { ActivityEvidence: true }
        });

        // ==================================================================================
        // 🟡 ZONE แจ้งเตือน: แจ้งเจ้าหน้าที่ว่ามีคนส่งงาน (Optional)
        // ==================================================================================
        /*
        const officerLineID = sourcePost.Officer?.User?.LineUserID;
        if (officerLineID) {
             const msg = `📝 มีการส่งงานใหม่!\nกิจกรรม: ${sourcePost.Title}\nโดย: UserID ${UserID}`;
             // await sendLineMessage(officerLineID, msg);
        }
        */
        // ==================================================================================

        res.json({ message: "ส่งข้อมูลกิจกรรมเรียบร้อยแล้ว", data: newActivity });

    } catch (err) {
        console.log(err);
        res.status(500).json({ message: "Server Error: " + err.message });
    }
};