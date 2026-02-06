const cron = require('node-cron');
const prisma = require('../prisma/prisma');
const startCronJob = () => {
    cron.schedule('* * * * *', async () => {
        const now = new Date();
        const options = { 
            timeZone: 'Asia/Bangkok', 
            hour: '2-digit', 
            minute: '2-digit', 
            second: '2-digit',
            hour12: false 
        };
        const timeString = now.toLocaleTimeString('th-TH', options);
        console.log(`⏰ [${timeString}] noticheck`);
        try {
            // --- ขั้นตอนที่ 1: ค้นหา (Find) ---
            // หาอันที่เวลายังน้อยกว่าหรือเท่ากับปัจจุบัน (ผ่านมาแล้ว) และยังไม่ส่ง
            const pendingNotifications = await prisma.notification.findMany({
                where: {
                    IsSent: false,
                    NotificationTime: {
                        lte: now // ✅ Logic นี้ถูกต้องแล้วครับ คือ "เวลาแจ้งเตือน <= เวลาปัจจุบัน"
                    }
                }
            });
            // ถ้าไม่มีรายการ ก็จบการทำงานรอบนี้
            if (pendingNotifications.length === 0) {
                console.log('💤 ไม่มีแจ้งเตือนที่ต้องส่ง');
                return;
            }
            console.log(`Found ${pendingNotifications.length} notifications.`);
            // --- ขั้นตอนที่ 2: ประมวลผล (Process) ---
            // เราต้องมีข้อมูลก่อน ถึงจะรู้ว่า Title คืออะไร UserID ไหน
            const notificationIds = [];
            for (const noti of pendingNotifications) {
                // ตรงนี้คือจุดที่คุณจะ "ส่ง" จริงๆ
                console.log(`🚀 กำลังส่ง: "${noti.Title}" ไปหา UserID: ${noti.UserID}`);
                // เก็บ ID ไว้เพื่อไปอัปเดตทีเดียว
                notificationIds.push(noti.NotificationID);
            }
            // --- ขั้นตอนที่ 3: อัปเดตสถานะ (Update) ---
            // เปลี่ยน IsSent เป็น true เฉพาะ ID ที่เราเพิ่งดึงมา
            await prisma.notification.updateMany({
                where: {
                    NotificationID: { in: notificationIds }
                },
                data: {
                    IsSent: true
                }
            });
            console.log('✅ อัปเดตสถานะเป็น "ส่งแล้ว" เรียบร้อย');
        } catch (error) {
            console.error('❌ Error in Cron Job:', error);
        }
    });
    cron.schedule('* * * * *', async () => { // ปรับเวลากลับเป็น 1 นาที หรือตามต้องการ
    const now = new Date();
        const options = { 
            timeZone: 'Asia/Bangkok', 
            hour: '2-digit', 
            minute: '2-digit', 
            second: '2-digit',
            hour12: false 
        };
        const timeString = now.toLocaleTimeString('th-TH', options);
        console.log(`⏰ [${timeString}] activityport check`);

    try {
        const expiredPorts = await prisma.activityPort.findMany({
            where: {
                EndDate: { lte: now },
                status: 'active', // ⚠️ ใน Schema คุณใช้ตัวเล็ก 'status' (เช็คดีๆนะครับ)
                Type: 'Scholarship' // ✅ แก้เป็น S ตัวใหญ่ ตาม enum PortType
            },
            include: {
                // ✅ แก้ตรงนี้: ใน schema คุณชื่อ "Activity" เฉยๆ
                Activity: true 
            }
        });

        if (expiredPorts.length > 0) {
            console.log(`🔎 พบ ${expiredPorts.length} พอร์ตที่หมดอายุ`);
            for (const port of expiredPorts) {
                // 1. คำนวณชั่วโมงที่ทำได้จริง (Sum HourofActivity)
                // port.Activity คือ Array ของกิจกรรมที่ดึงมาได้
                const totalHoursDone = port.Activity.reduce((sum, item) => {
                    // เช็ค status กิจกรรมด้วยไหม? เช่นต้อง 'approve' ถึงจะนับ
                    if (item.Status === 'waitforprocess' || item.Status === 'approve') {
                        return sum + (item.HourofActivity || 0);
                    }
                    return sum;
                }, 0);
                // 2. เป้าหมาย (HourNeed)
                const requiredHours = port.HourNeed || 0; 
                
                console.log(`   PortID ${port.ActivityPortID}: ทำได้ ${totalHoursDone}/${requiredHours}`);

                const isFailed = totalHoursDone < requiredHours;

                if (isFailed) {
                     console.log(`   ❌ ไม่ผ่านเกณฑ์ -> ดำเนินการแบน UserID ${port.UserID}`);

                     // เช็คและเพิ่ม Role แบน (RoleID 3)
                     const existingRole = await prisma.user_Role.findFirst({
                         where: { UserID: port.UserID, RoleID: 1 }
                     });
                     if (!existingRole) {
                         await prisma.user_Role.create({
                             data: { UserID: port.UserID, RoleID: 1 }
                         });
                         console.log(`      -> เพิ่ม Role ID 1 สำเร็จ`);
                     }
                    // อัปเดตสถานะพอร์ต
                    await prisma.activityPort.update({
                        where: { ActivityPortID: port.ActivityPortID }, // ✅ แก้เป็น ActivityPortID
                        data: { status: 'expired' } // หรือ 'expired' ตาม enum PortStatus
                    });
                } else {
                    console.log(`   ✅ ผ่านเกณฑ์`);
                    await prisma.activityPort.update({
                        where: { ActivityPortID: port.ActivityPortID },
                        data: { status: 'completed' }
                    });
                }
            }
        }
    } catch (error) {
        console.error('❌ CRON JOB ERROR:', error);
    }
});
};

module.exports = startCronJob;