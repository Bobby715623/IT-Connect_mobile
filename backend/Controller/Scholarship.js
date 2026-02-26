const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
exports.listScholarships = async (req, res) => {
    try {
        const scholarships = await prisma.scholarship.findMany({
            include: {
                Officer: true,
                ScholarshipRequirement: true
            }
        });
        res.json(scholarships);
    } catch (err) {
        console.log(err);
        res.status(500).json({ message: "Server Error" });
    }
};
exports.getScholarship = async (req, res) => {
    try {
        const { id } = req.params;
        const scholarship = await prisma.scholarship.findUnique({
            where: { ScholarshipID: Number(id) },
            include: {
                ScholarshipRequirement: true,
                ScholarshipApplication: {
                    include: { User: true }
                } 
            }
        });
        res.json(scholarship);
    } catch (err) {
        console.log(err);
        res.status(500).json({ message: "Server Error" });
    }
};
exports.createScholarship = async (req, res) => {
    try {
        const { 
            Scholarshipname, Description, Startdate, Enddate, 
            AnnouceStudentInterviewday, Interviewday, WinnerAnnouceday, 
            Picture, OfficerID,activityhour,
            Requirements
        } = req.body;
    
        const newScholarship = await prisma.scholarship.create({
            data: {
                Scholarshipname,
                Description,
                Startdate: new Date(Startdate),
                Enddate: new Date(Enddate),
                AnnouceStudentInterviewday: new Date(AnnouceStudentInterviewday),
                Interviewday: new Date(Interviewday),
                WinnerAnnouceday: new Date(WinnerAnnouceday),
                Picture,
                ActivityHourNeeded: Number(activityhour),
                OfficerID: Number(OfficerID),
                ScholarshipRequirement: {
                    create: Requirements.map(reqItem => ({
                        Name: reqItem.Name,
                        Type: reqItem.Type,
                        Require: reqItem.Require,
                        Description: reqItem.Description
                    }))
                }
            },
            include: { ScholarshipRequirement: true }
        });

        res.json(newScholarship);
    } catch (err) {
        console.log(err);
        res.status(500).json({ message: "Server Error" });
    }
};
exports.updateScholarship = async (req, res) => {
    try {
        const { id } = req.params;
        const { Scholarshipname, Description, Enddate } = req.body;

        const updated = await prisma.scholarship.update({
            where: { ScholarshipID: Number(id) },
            data: {
                Scholarshipname,
                Description,
                Enddate: new Date(Enddate)
            }
        });
        res.json(updated);
    } catch (err) {
        console.log(err);
        res.status(500).json({ message: "Server Error" });
    }
};
exports.removeScholarship = async (req, res) => {
    try {
        const { id } = req.params;
        await prisma.scholarship.delete({
            where: { ScholarshipID: Number(id) }
        });
        res.send("Scholarship Deleted");
    } catch (err) {
        console.log(err);
        res.status(500).json({ message: "Server Error" });
    }
};

//มอสแก้
exports.applyScholarship = async (req, res) => {
  try {
    const { ScholarshipID } = req.body;
    const userId = req.user.userId;

    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ message: 'No files uploaded' });
    }

    const submissions = JSON.parse(req.body.Submissions || '[]');

    if (submissions.length !== req.files.length) {
      return res.status(400).json({
        message: 'จำนวนไฟล์ไม่ตรงกับ Requirement'
      });
    }

    const application = await prisma.scholarshipApplication.create({
      data: {
        ScholarshipID: Number(ScholarshipID),
        UserID: Number(userId),
        ApplicationDate: new Date(),
        Status: 'waitingforprocess',
        ScholarshipSubmission: {
          create: req.files.map((file, index) => ({
            RequirementID: Number(submissions[index].RequirementID),
            StudentDocument: file.path
          }))
        }
      }
    });

    res.status(201).json(application);

  } catch (err) {

    // 👇 เพิ่มบล็อกนี้
    if (err.code === 'P2002') {
      return res.status(400).json({
        message: 'คุณได้สมัครทุนนี้ไปแล้ว'
      });
    }

    console.error('🔥 APPLY ERROR:', err);
    res.status(500).json({ message: 'Server Error', error: err.message });
  }
};





exports.myHistory = async (req, res) => {
  try {
    const userId = req.user.userId;


    const history = await prisma.scholarshipApplication.findMany({
      where: { UserID: userId },
      include: {
        Scholarship: true,
        ScholarshipSubmission: true,
      },
    });

    res.json(history);
  } catch (err) {
    console.log(err);
    res.status(500).json({ message: 'Server Error' });
  }
};

exports.updateApplicationStatus = async (req, res) => {
    try {
        const { applicationId,status } = req.params;
        const updatedApp = await prisma.scholarshipApplication.update({
            where: { ApplicationID: Number(applicationId) },
            data: { Status: status }
        });
        res.json(updatedApp);
    } catch (err) {
        console.log(err);
        res.status(500).json({ message: "Server Error" });
    }
};
exports.viewapplication = async (req, res) => {
    try {
        const { applicationid } = req.params;
        const application = await prisma.scholarshipApplication.findUnique({
            where: { ApplicationID: Number(applicationid) },
            include: {
                Scholarship: true, 
                User: {
                    select: {
                        UserID: true,
                        Email: true,
                        Student: {
                            select: {
                                StudentCode: true,
                                Name: true,
                                Surname: true,
                                Picture: true,
                                Year: true,
                            }
                        }
                    }
                },
                ScholarshipSubmission: {
                    include: {
                        ScholarshipRequirement: true
                    }
                }
            }
        });
        if (!application) {
            return res.status(404).json({ message: "ไม่พบข้อมูลใบสมัคร" });
        }
        res.status(200).json(application);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Server Error", error: error.message });
    }
};
exports.approveScholarship = async (req, res) => {
    try {
        const { applicationId } = req.params;
        const application = await prisma.scholarshipApplication.findUnique({
            where: { ApplicationID: Number(applicationId) },
            include: { Scholarship: true }
        });

        if (!application) return res.status(404).send("ไม่พบใบสมัคร");
        await prisma.scholarshipApplication.update({
            where: { ApplicationID: Number(applicationId) },
            data: { Status: 'approve' }
        });
        await prisma.activityPort.create({
            data: {
                UserID: application.UserID,
                Portname: `เก็บชั่วโมงกิจกรรม/จิตอาสาสำหรับทุน: ${application.Scholarship.Scholarshipname}`,
                Type: 'Scholarship',
                status: 'active',
                CreateDate: new Date(),
                EndDate: application.Scholarship.Enddate, 
                HourNeed: application.Scholarship.ActivityHourNeeded, 
                ScholarshipID: application.ScholarshipID 
            }
        });
        res.status(200).json({ message: "อนุมัติและสร้าง Port เรียบร้อยแล้ว" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
exports.viewscholarshipactivityport = async (req, res) => {
    try {
        const { scholarshipId} = req.params;
        const progressList = await prisma.activityPort.findMany({
        where: { 
            ScholarshipID: Number(scholarshipId) 
        },
        include: {
            User: {
                include: {
                    Student: true
                }
            },
            Activity: true
        }
    });
    res.status(200).json({ progressList });
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
}
exports.viewsinglescholarshipactivityport = async (req, res) => {
    try {
        const { activityportId} = req.params;
        const progressList = await prisma.activityPort.findMany({
        where: { 
            ActivityPortID: Number(activityportId) 
        },
        include: {
            User: {
                include: {
                    Student: true
                }
            },
            Activity: true
        }
    });
    res.status(200).json({ progressList });
    }
    catch (error) {
        res.status(500).json({ error: error.message });
    }
}

exports.removeApplication = async (req, res) => {
  try {
    const { applicationId } = req.params;

    await prisma.scholarshipApplication.delete({
      where: {
        ApplicationID: parseInt(applicationId),
      },
    });

    res.status(200).json({ message: "Application deleted successfully" });
  } catch (error) {
    console.error("DELETE ERROR:", error);
    res.status(500).json({ error: error.message });
  }
};