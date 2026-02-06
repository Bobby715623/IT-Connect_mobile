const prisma = require('../prisma/prisma');
exports.createSubject = async (req, res) => {
    try {
        const { Name, SubjectCode, MidtermExam, FinalExam } = req.body;
        const existingSubject = await prisma.subject.findFirst({
            where: { SubjectCode: SubjectCode }
        });

        if (existingSubject) {
            return res.status(400).json({ message: "รหัสวิชานี้มีอยู่ในระบบแล้ว" });
        }

        const newSubject = await prisma.subject.create({
            data: {
                Name,
                SubjectCode,
                MidtermExam: MidtermExam ? new Date(MidtermExam) : null,
                FinalExam: FinalExam ? new Date(FinalExam) : null,
            }
        });

        res.status(201).json({ message: "สร้างรายวิชาสำเร็จ", data: newSubject });

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "เกิดข้อผิดพลาด", error: error.message });
    }
};
exports.getAllSubjects = async (req, res) => {
    try {
        const subjects = await prisma.subject.findMany({
            include: {
                Subject_Sec: true 
            },
            orderBy: {
                SubjectCode: 'asc'
            }
        });
        res.status(200).json(subjects);
    } catch (error) {
        res.status(500).json({ message: "เกิดข้อผิดพลาด", error: error.message });
    }
};
exports.getSubjectById = async (req, res) => {
    try {
        const { subjectId } = req.params;
        const subject = await prisma.subject.findUnique({
            where: { SubjectID: Number(subjectId) },
            include: {
                Subject_Sec: true
            }
        });

        if (!subject) {
            return res.status(404).json({ message: "ไม่พบรายวิชานี้" });
        }

        res.status(200).json(subject);
    } catch (error) {
        res.status(500).json({ message: "เกิดข้อผิดพลาด", error: error.message });
    }
};
exports.updateSubject = async (req, res) => {
    try {
        const { subjectId } = req.params;
        const { Name, SubjectCode, MidtermExam, FinalExam } = req.body;

        const updatedSubject = await prisma.subject.update({
            where: { SubjectID: Number(subjectId) },
            data: {
                Name,
                SubjectCode,
                MidtermExam: MidtermExam ? new Date(MidtermExam) : undefined,
                FinalExam: FinalExam ? new Date(FinalExam) : undefined,
            }
        });

        res.status(200).json({ message: "อัปเดตข้อมูลสำเร็จ", data: updatedSubject });
    } catch (error) {
        if (error.code === 'P2025') {
            return res.status(404).json({ message: "ไม่พบรายวิชาที่จะแก้ไข" });
        }
        res.status(500).json({ message: "เกิดข้อผิดพลาด", error: error.message });
    }
};
exports.deleteSubject = async (req, res) => {
    try {
        const { subjectId } = req.params;
        await prisma.subject.delete({
            where: { SubjectID: Number(subjectId) }
        });
        res.status(200).json({ message: "ลบรายวิชาสำเร็จ" });
    } catch (error) {
        if (error.code === 'P2025') {
            return res.status(404).json({ message: "ไม่พบรายวิชาที่จะลบ" });
        }
        if (error.code === 'P2003') {
            return res.status(400).json({ message: "ไม่สามารถลบได้ เนื่องจากมีการเปิดสอน (Section) ในวิชานี้อยู่" });
        }
        res.status(500).json({ message: "เกิดข้อผิดพลาด", error: error.message });
    }
};
exports.createSection = async (req, res) => {
    try {
        const { Section, StartTime, EndTime, StudyTime, Professor, Classroom, SubjectID } = req.body;
        const existingSection = await prisma.subject_Sec.findFirst({
            where: {
                SubjectID: Number(SubjectID),
                Section: Number(Section)
            }
        });

        if (existingSection) {
            return res.status(400).json({ message: `Section ${Section} มีอยู่แล้วในรายวิชานี้ ไม่สามารถสร้างซ้ำได้` });
        }
        const newSec = await prisma.subject_Sec.create({
            data: {
                Section: Number(Section),
                StartTime: StartTime ? new Date(StartTime) : null, 
                EndTime: EndTime ? new Date(EndTime) : null,
                StudyTime,
                Professor,
                Classroom,
                SubjectID: Number(SubjectID)
            }
        });
        
        res.status(201).json(newSec);

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "เกิดข้อผิดพลาด", error: error.message });
    }
};
exports.getSectionById = async (req, res) => {
    try {
        const { secId } = req.params; 
        const sec = await prisma.subject_Sec.findUnique({
            where: { SecID: Number(secId) },
            include: {
                Subject: true,
                Student_Enroll: {
                    include: {
                        User: {
                            select: {
                                UserID: true,
                                Username: true,
                                Student: true 
                            }
                        }
                    }
                }
            }
        });

        if (!sec) return res.status(404).json({ message: "ไม่พบข้อมูล Section นี้" });
        
        res.status(200).json(sec);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
exports.updateSection = async (req, res) => {
    try {
        const { secId } = req.params;
        const data = req.body;
        if (data.StartTime) data.StartTime = new Date(data.StartTime);
        if (data.EndTime) data.EndTime = new Date(data.EndTime);

        const updatedSec = await prisma.subject_Sec.update({
            where: { SecID: Number(secId) },
            data: data
        });
        res.status(200).json(updatedSec);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
exports.deleteSection = async (req, res) => {
    try {
        const { secId } = req.params;
        await prisma.subject_Sec.delete({
            where: { SecID: Number(secId) }
        });
        res.status(200).json({ message: "Deleted successfully" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
exports.enrollStudent = async (req, res) => {
    try {
        const { UserID, SecID } = req.body;
        const existing = await prisma.student_Enroll.findFirst({
            where: { UserID: Number(UserID), SecID: Number(SecID) }
        });
        if (existing) return res.status(400).json({ message: "User already enrolled in this section" });

        const newEnroll = await prisma.student_Enroll.create({
            data: {
                UserID: Number(UserID),
                SecID: Number(SecID)
            }
        });
        res.status(201).json(newEnroll);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
exports.getStudentSchedule = async (req, res) => {
    try {
        const { userId } = req.params;
        const enrolls = await prisma.student_Enroll.findMany({
            where: { UserID: Number(userId) },
            include: {
                Subject_Sec: {
                    include: {
                        Subject: true
                    }
                }
            }
        });
        res.status(200).json(enrolls);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
exports.getStudentsInSec = async (req, res) => {
    try {
        const { secId } = req.params;
        const students = await prisma.student_Enroll.findMany({
            where: { SecID: Number(secId) },
            include: {
                User: {
                    include: { Student: true }
                }
            }
        });
        res.status(200).json(students);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
exports.withdraw = async (req, res) => {
    try {
        const { enrollId } = req.params;
        await prisma.student_Enroll.delete({
            where: { Student_EnrollID: Number(enrollId) }
        });
        res.status(200).json({ message: "Withdrawn successfully" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};