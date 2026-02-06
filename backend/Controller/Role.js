const prisma = require('../prisma/prisma');
exports.createrole = async (req, res) => {
    try {
        const { rolename } = req.body;
        const newEvent = await prisma.role.create({
            data: {
                RoleName:rolename
            }
        });
        res.status(201).json({ message: "เพิ่มRoleสำเร็จ", data: newEvent });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
exports.getrole = async (req, res) => {
    try {
        const allrole = await prisma.role.findMany();
        res.status(200).json(allrole);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
exports.getuserrole = async (req, res) => {
    try {
        const { userId } = req.params;
        const userrole = await prisma.user_Role.findMany({
            where: { UserID: Number(userId) },
            include: { Role: true },
        });
        if (!userrole || userrole.length === 0) {
            return res.status(404).json({ message: "User คนนี้ยังไม่มี Role" });
        }
        res.status(200).json(userrole);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
exports.editrole = async (req, res) => {
    try {
        const { roleId } = req.params;
        const {rolename} = req.body;
        const updaterole = await prisma.role.update({
            where: { RoleID: Number(roleId) },
            data: {
                RoleName: rolename
            }
        });
       res.status(200).json({ message: "แก้ไข Role เสร็จ", data: updaterole });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
exports.addroletouser = async (req, res) => {
    try {
        const { userId,roleId } = req.params;
        const addrole = await prisma.user_Role.create({
            data: {
                UserID: Number(userId),
                RoleID: Number(roleId)
            }
        });
        res.status(200).json({ message: "เพิ่มRoleให้Userเร็จ", data: addrole });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
exports.delrolefromuser = async (req, res) => {
    try {
        const { userId,roleId } = req.params;
        const addrole = await prisma.user_Role.deleteMany({
            where: {
                UserID: Number(userId),
                RoleID: Number(roleId)
            }
        });
        res.status(200).json({ message: "ลบRoleจากuserแล้ว", data: addrole });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
exports.deleterole = async (req, res) => {
    try {
        const { roleId } = req.params;
        await prisma.role.delete({
            where: { RoleID: Number(roleId) }
        });
        res.status(200).json({ message: "ลบRoleเสร็จแล้ว" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};