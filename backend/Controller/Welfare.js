const prisma = require('../prisma/prisma');
exports.infowelfare = async (req, res) => {
  try {
    const { welfareId } = req.params;
    const welfare = await prisma.welfare.findUnique({
      where: {
        WelfareID: Number(welfareId),
      },
      include: {
        Officer: true
      }
    });
    res.json(welfare);
  } catch (err) {
    res.status(500).send('There is an error: ' + err.message)
  }
};
exports.welfarelist = async (req, res) => {
  try {
    const welfarelist = await prisma.welfare.findMany({include: { Officer: true }});
    res.send(welfarelist);
  } catch (err) {
    res.status(500).send('There is an error: ' + er.message)
  }
};
exports.createwelfare = async (req, res) => {
    try {
      console.log(req.body);
        const { 
            officerId,
            Welfaretype, welfaretitle, description, welfareguide, welfaredocument
        } = req.body;
        if (!officerId) {
            return res.status(400).send('OfficerID is required');
        }
        const newWelfare = await prisma.welfare.create({
            data: {
                WelfareType: Welfaretype,
                WelfareTitle: welfaretitle,
                Description: description,
                WelfareGuide: welfareguide,
                WelfareDocument: welfaredocument,
                Officer: {
                    connect: {
                        OfficerID: Number(officerId)
                    }
                },
            },
            include: {
                Officer: true
            }
        });
        res.send(newWelfare);
    } catch (error) {
        console.log(error);
        res.status(500).send('Error: ' + error.message);
    }
};
exports.editwelfare = async (req, res) => {
    try {
        const { welfareId } = req.params;
        const { 
            Welfaretype, welfaretitle, description, welfareguide, welfaredocument 
        } = req.body;

        const updatedWelfare = await prisma.welfare.update({
            where: {
                WelfareID: Number(welfareId)
            },
            data: {
                WelfareType: Welfaretype,
                WelfareTitle: welfaretitle,
                Description: description,
                WelfareGuide: welfareguide,
                WelfareDocument: welfaredocument
            }
        });
        res.send(updatedWelfare);
    } catch (error) {
        console.log(error);
        res.status(500).send('There is an error: ' + error.message);
    }
};
exports.removewelfare = async (req, res) => {
  const { welfareId } = req.params;
  try {
    const deletedwelfare = await prisma.welfare.delete({
      where: { WelfareID: Number(welfareId) },
    });
    res.send(deletedwelfare);
  } catch (err) {
    res.status(500).send('There is an error: ' + err)
  }
}
