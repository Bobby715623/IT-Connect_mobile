const prisma = require('../prisma/prisma');
exports.singlepost = async (req, res) => {
  try {
    const { postId } = req.params;
    const post = await prisma.post.findUnique({
      where: {
        PostID: Number(postId),
      },
    });
    res.json(post);
  } catch (err) {
    res.status(500).send('There is an error: ' + error.message)
  }
};
exports.postlistofficer = async (req, res) => {
  try {
    const postlist = await prisma.post.findMany();
    res.send(postlist);
  } catch (err) {
    res.status(500).send('There is an error: ' + error.message)
  }
};
exports.postliststudent = async (req, res) => {
  try {
    const postlist = await prisma.post.findMany();
    res.send(postlist);
  } catch (err) {
    res.status(500).send('There is an error: ' + error.message)
  }
};
exports.createpost = async (req, res) => {
    try {
        const { 
            Content, Type, IsPinned, NotifyType, TargetType,
            Schedule_Time, ExpireDate, CanComment, OfficerID,
            Pictures
        } = req.body;
        if (!OfficerID) {
            return res.status(400).send('OfficerID is required');
        }
        const newPost = await prisma.post.create({
            data: {
                Content: Content,
                Type: Type,             // ต้องตรงกับ Enum: normal, scholarship, Welfare, education
                IsPinned: IsPinned,
                NotifyType: NotifyType, // ต้องตรงกับ Enum: urgent, schedule, normal
                TargetType: TargetType, // ต้องตรงกับ Enum: public, bystudent, byrole
                // แปลงเป็น Date object เพื่อความชัวร์
                Schedule_Time: Schedule_Time ? new Date(Schedule_Time) : null,
                ExpireDate: ExpireDate ? new Date(ExpireDate) : null,
                CreateDate: new Date(), // สร้างวันที่ปัจจุบันอัตโนมัติ
                CanComment: CanComment,
                // เชื่อมกับ Officer (คนโพสต์)
                Officer: {
                    connect: {
                        OfficerID: Number(OfficerID)
                    }
                },
                // *** เพิ่มเติม: วิธีบันทึกรูปภาพพร้อมโพสต์ทีเดียว (ถ้ามี) ***
                PostPicture: (Pictures && Pictures.length > 0) ? {
                    create: Pictures.map((url) => ({
                        Picture: url
                    }))
                } : undefined
            },
            include: {
                PostPicture: true, // ให้ส่งข้อมูลรูปภาพกลับมาให้ดูด้วย
                Officer: true      // ให้ส่งข้อมูลคนโพสต์กลับมาให้ดูด้วย
            }
        });

        res.send(newPost);

    } catch (error) {
        console.log(error);
        res.status(500).send('There is an error: ' + error.message);
    }
};
exports.updatepost = async (req, res) => {
    try {
        const { postId } = req.params; 
        const { 
            Content, 
            IsPinned, 
            Schedule_Time, 
            ExpireDate, 
            CanComment,
            Pictures
        } = req.body;
        const updatedPost = await prisma.post.update({
            where: {
                PostID: Number(postId)
            },
            data: {
                Content: Content,
                IsPinned: IsPinned,
                CanComment: CanComment,
                Schedule_Time: Schedule_Time ? new Date(Schedule_Time) : undefined,
                ExpireDate: ExpireDate ? new Date(ExpireDate) : undefined,
                PostPicture: (Pictures && Pictures.length > 0) ? {
                    deleteMany: {},
                    create: Pictures.map((url) => ({
                        Picture: url
                    }))
                } : undefined
            },
            include: {
                PostPicture: true
            }
        });

        res.send(updatedPost);

    } catch (error) {
        console.log(error);
        res.status(500).send('There is an error: ' + error.message);
    }
};
exports.removepost = async (req, res) => {
  const { postId } = req.params;
  try {
    const deletedpost = await prisma.post.delete({
      where: { PostID: Number(postId) },
    });
    res.send(deletedpost);
  } catch (err) {
    res.status(500).send('There is an error: ' + err)
  }
}
//comment
exports.comment = async (req, res) => {
    try {
        const { postId } = req.params; 
        const { 
            Content, 
            UserID,         
            Parent_comment
        } = req.body;

        if (!UserID) return res.status(400).send('UserID is required');
        if (!Content) return res.status(400).send('Content cannot be empty');

        const newComment = await prisma.postComment.create({
            data: {
                Content: Content,
                Comment_at: new Date(),
                Parent: Parent_comment ? {
                    connect: {
                        CommentID: Number(Parent_comment)
                    }
                } : undefined,
                Post: {
                    connect: { PostID: Number(postId) }
                },
                User: {
                    connect: { UserID: Number(UserID) }
                }
            },
            include: {
                User: {
                    select: { 
                        Username: true, 
                    }
                }
            }
        });

        res.send(newComment);

    } catch (error) {
        console.log(error);
        res.status(500).send('There is an error: ' + error.message);
    }
};
exports.removecomment = async (req, res) => {
  try {
    const { postId, commentId } = req.params; 

    const deletedComment = await prisma.postComment.delete({
      where: { 
        CommentID: Number(commentId)
      },
    });

    res.send(deletedComment);

  } catch (err) {
    console.log(err);
    res.status(500).send('Error: ' + err.message);
  }
}