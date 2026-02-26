const prisma = require('../prisma/prisma');


// =============================
// GET ONE
// =============================
exports.infowelfare = async (req, res) => {
  try {
    const { welfareId } = req.params;

    const welfare = await prisma.welfare.findUnique({
      where: {
        WelfareID: Number(welfareId),
      },
      include: {
        Officer: true,
        Files: true
      },
    });

    res.json(welfare);

  } catch (err) {
    console.log(err);
    res.status(500).json({ error: err.message });
  }
};


// =============================
// GET ALL
// =============================
exports.welfarelist = async (req, res) => {
  try {
    const welfarelist = await prisma.welfare.findMany({
      include: {
        Officer: true,
        Files: true
      },
    });

    res.json(welfarelist);

  } catch (err) {
    console.log(err);
    res.status(500).json({ error: err.message });
  }
};


// =============================
// CREATE welfare
// =============================
exports.createwelfare = async (req, res) => {
  try {
    const {
      WelfareType,
      Title,
      Description,
      CoverImage,
      OfficerID,
      Files
    } = req.body;

    if (!OfficerID) {
      return res.status(400).json({ error: 'OfficerID is required' });
    }

    if (!Title) {
      return res.status(400).json({ error: 'Title is required' });
    }

    const newWelfare = await prisma.welfare.create({
      data: {
        WelfareType,
        Title,
        Description,
        CoverImage: CoverImage ?? null,

        Officer: {
          connect: { OfficerID: Number(OfficerID) }
        },

        // ✅ ใส่ Files เฉพาะตอนมีจริง ๆ
        ...(Files && Files.length > 0 && {
          Files: {
            create: Files.map(file => ({
              FileName: file.FileName,
              FileUrl: file.FileUrl,
              FileType: file.FileType
            }))
          }
        })
      },
      include: {
        Officer: true,
        Files: true
      }
    });

    res.json(newWelfare);

  } catch (error) {
    console.log(error);
    res.status(500).json({ error: error.message });
  }
};


// =============================
// UPDATE Welfare
// =============================
exports.editwelfare = async (req, res) => {
  try {
    const { welfareId } = req.params;

    const {
      Title,
      Description,
      CoverImage
    } = req.body;

    const updatedWelfare = await prisma.welfare.update({
      where: {
        WelfareID: Number(welfareId)
      },
      data: {
        Title,
        Description,
        CoverImage
      },
      include: {
        Files: true,
        Officer: true
      }
    });

    res.json(updatedWelfare);

  } catch (error) {
    console.log(error);
    res.status(500).json({ error: error.message });
  }
};


// =============================
// DELETE welfare
// =============================
exports.removewelfare = async (req, res) => {
  try {
    const { welfareId } = req.params;

    const deletedwelfare = await prisma.welfare.delete({
      where: {
        WelfareID: Number(welfareId)
      }
    });

    res.json(deletedwelfare);

  } catch (err) {
    console.log(err);
    res.status(500).json({ error: err.message });
  }
};

//เอาไว้ใช้เรียกไป welfare type scholarship
exports.getScholarshipWelfare = async (req, res) => {
  try {
    const welfare = await prisma.welfare.findFirst({
      where: { WelfareType: "scholarship" },
      include: {
        Officer: true,
        Files: true
      }
    });

    res.json(welfare);
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: err.message });
  }
};

exports.getWelfareByType = async (req, res) => {
  try {
    const { type } = req.params;

    const welfareList = await prisma.welfare.findMany({
      where: {
        WelfareType: type
      },
      include: {
        Files: true,
        Officer: true
      }
    });

    res.json(welfareList);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Server error" });
  }
};
///ฝั่งเจ้าหน้าที่ต้องเขียน update welfare file ด้วยนะ เพราะสามารถเพิ่มได้มากกว่าหนึ่งไฟล์ ใน welfare type