const prisma = require('../prisma/prisma');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { OAuth2Client } = require('google-auth-library');

exports.read = async (req, res) => {
  try {
    const { userId } = req.params;
    const user = await prisma.user.findUnique({
      where: {
        UserID: Number(userId),
      },
    });
    res.json(user);
  } catch (err) {
    res.status(500).send('There is an error: ' + error.message)
  }
};
exports.list = async (req, res) => {
  try {
    const userlist = await prisma.user.findMany();
    res.send(userlist);
  } catch (err) {
    res.status(500).send('There is an error: ' + error.message)
  }
};
exports.create = async (req, res) => {
    try {
        const { 
            Username, Password, Email, Type, GoogleID,
            Name, Surname, Year, Semester, Picture, StudentCode 
        } = req.body;
        let hashedPassword = null;
        let finalUsername = null;
        if (Type === 'Officer') {
            if (!Username || !Password) {
                return res.status(400).send('Officer ต้องมี Username และ Password');
            }
            const checkUser = await prisma.user.findFirst({ where: { Username: Username } });
            if (checkUser) {
                return res.status(400).send('Username นี้ถูกใช้งานแล้ว');
            }
            const salt = await bcrypt.genSalt(10);
            hashedPassword = await bcrypt.hash(Password, salt);
            finalUsername = Username;
        }
        else if (Type === 'Student') {
            if (!GoogleID) {
                return res.status(400).send('Student ต้องมี GoogleID');
            }
            const checkGoogle = await prisma.user.findFirst({ where: { GoogleID: GoogleID } });
            if (checkGoogle) {
                return res.status(400).send('GoogleID นี้ถูกใช้งานแล้ว');
            }
            finalUsername = null;
            hashedPassword = null;
        }
        const newUser = await prisma.user.create({
            data: {
                Username: finalUsername,
                Password: hashedPassword,
                Email: Email,
                Type: Type,
                GoogleID: GoogleID,
                Student: Type === 'Student' ? { 
                    create: {
                        StudentCode: StudentCode ? Number(StudentCode) : null,
                        Year: Year, 
                        Name: Name,
                        Surname: Surname,
                        Picture: Picture,
                        Semester: Semester ? Number(Semester) : null,
                    } 
                } : undefined,
                Officer: Type === 'Officer' ? { 
                    create: {
                        Name: Name,
                        Surname: Surname,
                        Picture: Picture,
                    } 
                } : undefined,
            },
            include: {
                Student: true,
                Officer: true
            }
        })
        res.send(newUser)
    } catch (error) {
        console.log(error);
        res.status(500).send('There is an error: ' + error.message)
    }
}
exports.update = async (req, res) => {
    const { userId } = req.params;
    const { Username, Password, Email, Type, GoogleID } = req.body;
  try {
    const updateuser = await prisma.User.update({
      where: { UserID: Number(userId) },
      data: {
        Username: Username,
        Password: Password,
        Email: Email,
        Type: Type,
        GoogleID: GoogleID
      },
    });
    res.json(updateuser);
  } catch (err) {
    res.status(500).send('There is an error: ' + error.message)
  }
};
exports.remove = async (req, res) => {
  const { userId } = req.params;
  try {
    const deletedOfficer = await prisma.User.delete({
      where: { UserID: Number(userId) },
    });
    res.send(deletedOfficer);
  } catch (err) {
    res.status(500).send('There is an error: ' + error.message)
  }
}
exports.login = async (req, res) => {
  try {
    const { Username, Password } = req.body;
    // ค้นหา User
    const user = await prisma.user.findFirst({
      where: { Username: Username },
      include: { Officer: true }
    });
    // 2. [แก้บั๊ก] ต้องเช็คว่ามี User ไหม 'ก่อน' จะไปเช็ครหัสผ่าน
    // ไม่งั้นถ้า user เป็น null โค้ดบรรทัดถัดไปจะ error ทันที
    if (!user) {
       return res.status(401).send('ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง');
    }
    // เช็ครหัสผ่าน
    const isMatch = await bcrypt.compare(Password, user.Password);
    if (!isMatch) {
      return res.status(401).send('ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง');
    }
    // --- ส่วนที่เพิ่มเข้ามา: การสร้าง JWT ---
    // 3. เตรียมข้อมูลที่จะฝังลงใน Token (Payload)
    // เอาแค่ข้อมูลสำคัญๆ พอ ไม่ต้องเอาไปหมดทั้งก้อน User
    const payload = {
      id: user.id,
      username: user.Username,
      role: user.Type // หรือใช้ user.Officer ? ขึ้นอยู่กับว่าคุณแยกสิทธิ์ยังไง
    };
    // 4. สร้าง Token (Sign)
    // 'secret_key_ja' คือกุญแจลับ (ควรย้ายไปเก็บใน .env ถ้าทำจริง)
    // expiresIn: '1d' คือบัตรนี้ใช้ได้ 1 วัน
    const token = jwt.sign(payload, process.env.JWT_SECRET || 'secret_key_ja', { expiresIn: '1d' });
    // --- จบส่วนสร้าง Token ---
    // เตรียมข้อมูล User ที่จะส่งกลับ (ตัดรหัสผ่านออกเหมือนเดิม)
    const userData = { ...user };
    delete userData.Password;
    // 5. ส่งกลับไปทั้ง Token และ ข้อมูล User
    res.json({
      token: token, // <--- สำคัญ! ส่งกุญแจให้ Frontend
      user: userData 
    });

  } catch (err) {
    console.log(err);
    res.status(500).send('Server Error');
  }
};


//Student login (มอสเพิ่ม)
const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

exports.googleLogin = async (req, res) => {
  try {
    const { idToken } = req.body;


    if (!idToken) {
      return res.status(400).json({ message: 'Missing idToken' });
    }

    // 🔐 Verify Google Token
    const ticket = await client.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID,
    });

    const payload = ticket.getPayload();

    const {
      sub: googleId,
      email,
      name,
      picture,
    } = payload;

    // 🔎 Find user by GoogleID
    let user = await prisma.user.findUnique({
      where: { GoogleID: googleId },
    });

    console.log('CHECK USER RESULT:', user); //check data user

    // ➕ Create user if not exist
    if (!user) {

      console.log('CREATING NEW USER');//check create user

      user = await prisma.user.create({
        data: {
          GoogleID: googleId,
          Email: email,
          Username: email,
          Type: 'Student', // ปรับตาม enum ของคุณ
        },
      });
    }

    // 🔑 Create JWT
    const token = jwt.sign(
      {
        userId: user.UserID,
        type: user.Type,
      },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    return res.json({ token, user });

  } catch (error) {
    console.error(error);
    return res.status(401).json({ message: 'Google login failed' });
  }
};