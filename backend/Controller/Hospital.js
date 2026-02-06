const prisma = require('../prisma/prisma');
exports.read = async (req, res) => {
  try {
    const { hosId } = req.params;
    const hospital = await prisma.hospital.findUnique({
      where: {
        HospitalID: Number(hosId),
      },
    });
    res.json(hospital);
  } catch (err) {
    res.status(500).send('There is an error: ' + err.message)
  }
};
exports.list = async (req, res) => {
  try {
    const hospitallist = await prisma.hospital.findMany();
    res.send(hospitallist);
  } catch (err) {
    res.status(500).send('There is an error: ' + err.message)
  }
};
exports.create = async(req,res)=>{
    try {
        const { 
            HospitalName, PlaceID, OfficerID, PhotoUrl, Province, Latitude, Longitude
        } = req.body;

        const newHos = await prisma.hospital.create({
            data: {
                HospitalName: HospitalName,
                PlaceID: PlaceID,
                photourl: PhotoUrl,
                province: Province,
                latitude: Latitude,
                longitude: Longitude,
                Officer: {
                    connect: {
                        OfficerID: Number(OfficerID)
                    }
                }
            }
        })
        res.send(newHos)
    } catch (err) {
        console.log("ERROR DETAIL:", err); 
        res.status(500).send('There is an error: ' + err.message)
    }
}
exports.remove = async (req, res) => {
  const { hosId } = req.params;
  try {
    const deletedhospital = await prisma.hospital.delete({
      where: { HospitalID: Number(hosId) },
    });
    res.send(deletedhospital);
  } catch (err) {
    res.status(500).send('There is an error: ' + err.message)
  }
}