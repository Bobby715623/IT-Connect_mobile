-- CreateTable
CREATE TABLE `User` (
    `UserID` INTEGER NOT NULL AUTO_INCREMENT,
    `Username` VARCHAR(191) NULL,
    `Password` VARCHAR(191) NULL,
    `Type` ENUM('Student', 'Officer') NULL,
    `GoogleID` VARCHAR(191) NULL,
    `Email` VARCHAR(191) NULL,

    UNIQUE INDEX `User_Username_key`(`Username`),
    UNIQUE INDEX `User_Email_key`(`Email`),
    PRIMARY KEY (`UserID`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Student` (
    `StudentID` INTEGER NOT NULL AUTO_INCREMENT,
    `StudentCode` INTEGER NULL,
    `Year` INTEGER NULL,
    `Name` VARCHAR(191) NULL,
    `Surname` VARCHAR(191) NULL,
    `Picture` VARCHAR(191) NULL,
    `Semester` INTEGER NULL,
    `UserID` INTEGER NOT NULL,

    UNIQUE INDEX `Student_StudentCode_key`(`StudentCode`),
    UNIQUE INDEX `Student_UserID_key`(`UserID`),
    PRIMARY KEY (`StudentID`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Officer` (
    `OfficerID` INTEGER NOT NULL AUTO_INCREMENT,
    `Name` VARCHAR(191) NULL,
    `Surname` VARCHAR(191) NULL,
    `Picture` VARCHAR(191) NULL,
    `UserID` INTEGER NOT NULL,

    UNIQUE INDEX `Officer_UserID_key`(`UserID`),
    PRIMARY KEY (`OfficerID`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `User_Role` (
    `User_RoleID` INTEGER NOT NULL AUTO_INCREMENT,
    `RoleID` INTEGER NOT NULL,
    `UserID` INTEGER NOT NULL,

    PRIMARY KEY (`User_RoleID`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Role` (
    `RoleID` INTEGER NOT NULL AUTO_INCREMENT,
    `RoleName` VARCHAR(191) NULL,

    PRIMARY KEY (`RoleID`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Student_Enroll` (
    `Student_EnrollID` INTEGER NOT NULL AUTO_INCREMENT,
    `SecID` INTEGER NOT NULL,
    `UserID` INTEGER NOT NULL,

    PRIMARY KEY (`Student_EnrollID`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Subject` (
    `SubjectID` INTEGER NOT NULL AUTO_INCREMENT,
    `Name` VARCHAR(191) NULL,
    `SubjectCode` VARCHAR(191) NULL,
    `MidtermExam` DATETIME(3) NULL,
    `FinalExam` DATETIME(3) NULL,

    PRIMARY KEY (`SubjectID`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Subject_Sec` (
    `SecID` INTEGER NOT NULL AUTO_INCREMENT,
    `Section` INTEGER NULL,
    `StartTime` DATETIME(3) NULL,
    `EndTime` DATETIME(3) NULL,
    `StudyTime` ENUM('Monday', 'Tuesday', 'Wendesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') NULL,
    `Professor` VARCHAR(191) NULL,
    `Classroom` VARCHAR(191) NULL,
    `SubjectID` INTEGER NOT NULL,

    PRIMARY KEY (`SecID`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `PersonalEvent` (
    `PersonalEventID` INTEGER NOT NULL AUTO_INCREMENT,
    `Title` VARCHAR(191) NULL,
    `Description` VARCHAR(191) NULL,
    `Deadline` DATETIME(3) NULL,
    `Notify` BOOLEAN NULL,
    `NotifyDatetime` DATETIME(3) NULL,
    `UserID` INTEGER NOT NULL,

    PRIMARY KEY (`PersonalEventID`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Notification` (
    `NotificationID` INTEGER NOT NULL AUTO_INCREMENT,
    `Title` VARCHAR(191) NULL,
    `Message` VARCHAR(191) NULL,
    `IsRead` BOOLEAN NULL,
    `NotificationType` ENUM('scholarship', 'activity', 'news', 'selfevent') NULL,
    `ActionURL` VARCHAR(191) NULL,
    `NotificationTime` DATETIME(3) NULL,
    `UserID` INTEGER NOT NULL,

    PRIMARY KEY (`NotificationID`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Activity` (
    `ActivityID` INTEGER NOT NULL AUTO_INCREMENT,
    `ActivityName` VARCHAR(191) NULL,
    `Description` VARCHAR(191) NULL,
    `HourofActivity` INTEGER NULL,
    `Location` VARCHAR(191) NULL,
    `DatetimeofActivity` DATETIME(3) NULL,
    `Status` ENUM('waitforprocess', 'approve', 'reject') NULL,
    `Comment` VARCHAR(191) NULL,
    `ActivityPortID` INTEGER NOT NULL,

    PRIMARY KEY (`ActivityID`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `ActivityEvidence` (
    `EvidenceID` INTEGER NOT NULL AUTO_INCREMENT,
    `Picture` VARCHAR(191) NULL,
    `ActivityID` INTEGER NOT NULL,

    PRIMARY KEY (`EvidenceID`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `ActivityPort` (
    `ActivityPortID` INTEGER NOT NULL AUTO_INCREMENT,
    `Portname` VARCHAR(191) NULL,
    `HourNeed` INTEGER NULL,
    `Type` ENUM('Custom', 'Scholarship') NULL,
    `CreateDate` DATETIME(3) NULL,
    `EndDate` DATETIME(3) NULL,
    `UserID` INTEGER NOT NULL,

    PRIMARY KEY (`ActivityPortID`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `ActivityPost` (
    `ActivityPostID` INTEGER NOT NULL AUTO_INCREMENT,
    `Title` VARCHAR(191) NULL,
    `Description` VARCHAR(191) NULL,
    `HourofActivity` INTEGER NULL,
    `Location` VARCHAR(191) NULL,
    `DatetimeofActivity` DATETIME(3) NULL,
    `OfficerID` INTEGER NOT NULL,

    PRIMARY KEY (`ActivityPostID`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Follow_ActivityPost` (
    `Follow_ActivityID` INTEGER NOT NULL AUTO_INCREMENT,
    `ActivityPostID` INTEGER NOT NULL,
    `UserID` INTEGER NOT NULL,

    PRIMARY KEY (`Follow_ActivityID`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Scholarship` (
    `ScholarshipID` INTEGER NOT NULL AUTO_INCREMENT,
    `Scholarshipname` VARCHAR(191) NULL,
    `Description` VARCHAR(191) NULL,
    `Startdate` DATETIME(3) NULL,
    `Enddate` DATETIME(3) NULL,
    `AnnouceStudentInterviewday` DATETIME(3) NULL,
    `Interviewday` DATETIME(3) NULL,
    `WinnerAnnouceday` DATETIME(3) NULL,
    `Picture` VARCHAR(191) NULL,
    `OfficerID` INTEGER NOT NULL,

    PRIMARY KEY (`ScholarshipID`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `ScholarshipRequirement` (
    `RequirementID` INTEGER NOT NULL AUTO_INCREMENT,
    `Name` VARCHAR(191) NULL,
    `Type` ENUM('picture', 'document') NULL,
    `Require` BOOLEAN NULL,
    `Description` VARCHAR(191) NULL,
    `ScholarshipID` INTEGER NOT NULL,

    PRIMARY KEY (`RequirementID`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `ScholarshipApplication` (
    `ApplicationID` INTEGER NOT NULL AUTO_INCREMENT,
    `ApplicationDate` DATETIME(3) NULL,
    `Status` ENUM('waitingforprocess', 'reject', 'waitforinterview', 'approve') NULL,
    `ScholarshipID` INTEGER NOT NULL,
    `UserID` INTEGER NOT NULL,

    PRIMARY KEY (`ApplicationID`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `ScholarshipSubmission` (
    `SubmissionID` INTEGER NOT NULL AUTO_INCREMENT,
    `StudentDocument` VARCHAR(191) NULL,
    `ApplicationID` INTEGER NOT NULL,
    `RequirementID` INTEGER NOT NULL,

    PRIMARY KEY (`SubmissionID`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Welfare` (
    `WelfareID` INTEGER NOT NULL AUTO_INCREMENT,
    `WelfareType` ENUM('registercourse', 'helthcare', 'scholarship', 'petition') NULL,
    `WelfareTitle` VARCHAR(191) NULL,
    `Description` VARCHAR(191) NULL,
    `WelfareGuide` VARCHAR(191) NULL,
    `WelfareDocument` VARCHAR(191) NULL,
    `OfficerID` INTEGER NOT NULL,

    PRIMARY KEY (`WelfareID`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Hospital` (
    `HospitalID` INTEGER NOT NULL AUTO_INCREMENT,
    `HospitalName` VARCHAR(191) NULL,
    `PlaceID` VARCHAR(191) NULL,
    `OfficerID` INTEGER NOT NULL,

    PRIMARY KEY (`HospitalID`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Post` (
    `PostID` INTEGER NOT NULL AUTO_INCREMENT,
    `Content` VARCHAR(191) NULL,
    `Type` ENUM('normal', 'scholarship', 'Welfare', 'education') NULL,
    `IsPinned` BOOLEAN NULL,
    `NotifyType` ENUM('urgent', 'schedule', 'normal') NULL,
    `TargetType` ENUM('public', 'bystudent', 'byrole') NULL,
    `Schedule_Time` DATETIME(3) NULL,
    `ExpireDate` DATETIME(3) NULL,
    `CreateDate` DATETIME(3) NULL,
    `CanComment` BOOLEAN NULL,
    `OfficerID` INTEGER NOT NULL,

    PRIMARY KEY (`PostID`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `PostPicture` (
    `PostPictureID` INTEGER NOT NULL AUTO_INCREMENT,
    `Picture` VARCHAR(191) NULL,
    `PostID` INTEGER NOT NULL,

    PRIMARY KEY (`PostPictureID`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `PostComment` (
    `CommentID` INTEGER NOT NULL AUTO_INCREMENT,
    `Content` VARCHAR(191) NULL,
    `Comment_at` DATETIME(3) NULL,
    `Parent_comment` INTEGER NULL,
    `PostID` INTEGER NOT NULL,
    `UserID` INTEGER NOT NULL,

    PRIMARY KEY (`CommentID`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `PostVisibility` (
    `PostVisibilityID` INTEGER NOT NULL AUTO_INCREMENT,
    `VisibilityType` ENUM('public', 'byrole', 'bystudent') NULL,
    `TargetID` INTEGER NULL,
    `PostID` INTEGER NOT NULL,

    PRIMARY KEY (`PostVisibilityID`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `Student` ADD CONSTRAINT `Student_UserID_fkey` FOREIGN KEY (`UserID`) REFERENCES `User`(`UserID`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Officer` ADD CONSTRAINT `Officer_UserID_fkey` FOREIGN KEY (`UserID`) REFERENCES `User`(`UserID`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `User_Role` ADD CONSTRAINT `User_Role_RoleID_fkey` FOREIGN KEY (`RoleID`) REFERENCES `Role`(`RoleID`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `User_Role` ADD CONSTRAINT `User_Role_UserID_fkey` FOREIGN KEY (`UserID`) REFERENCES `User`(`UserID`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Student_Enroll` ADD CONSTRAINT `Student_Enroll_SecID_fkey` FOREIGN KEY (`SecID`) REFERENCES `Subject_Sec`(`SecID`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Student_Enroll` ADD CONSTRAINT `Student_Enroll_UserID_fkey` FOREIGN KEY (`UserID`) REFERENCES `User`(`UserID`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Subject_Sec` ADD CONSTRAINT `Subject_Sec_SubjectID_fkey` FOREIGN KEY (`SubjectID`) REFERENCES `Subject`(`SubjectID`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `PersonalEvent` ADD CONSTRAINT `PersonalEvent_UserID_fkey` FOREIGN KEY (`UserID`) REFERENCES `User`(`UserID`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Notification` ADD CONSTRAINT `Notification_UserID_fkey` FOREIGN KEY (`UserID`) REFERENCES `User`(`UserID`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Activity` ADD CONSTRAINT `Activity_ActivityPortID_fkey` FOREIGN KEY (`ActivityPortID`) REFERENCES `ActivityPort`(`ActivityPortID`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `ActivityEvidence` ADD CONSTRAINT `ActivityEvidence_ActivityID_fkey` FOREIGN KEY (`ActivityID`) REFERENCES `Activity`(`ActivityID`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `ActivityPort` ADD CONSTRAINT `ActivityPort_UserID_fkey` FOREIGN KEY (`UserID`) REFERENCES `User`(`UserID`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `ActivityPost` ADD CONSTRAINT `ActivityPost_OfficerID_fkey` FOREIGN KEY (`OfficerID`) REFERENCES `Officer`(`OfficerID`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Follow_ActivityPost` ADD CONSTRAINT `Follow_ActivityPost_ActivityPostID_fkey` FOREIGN KEY (`ActivityPostID`) REFERENCES `ActivityPost`(`ActivityPostID`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Follow_ActivityPost` ADD CONSTRAINT `Follow_ActivityPost_UserID_fkey` FOREIGN KEY (`UserID`) REFERENCES `User`(`UserID`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Scholarship` ADD CONSTRAINT `Scholarship_OfficerID_fkey` FOREIGN KEY (`OfficerID`) REFERENCES `Officer`(`OfficerID`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `ScholarshipRequirement` ADD CONSTRAINT `ScholarshipRequirement_ScholarshipID_fkey` FOREIGN KEY (`ScholarshipID`) REFERENCES `Scholarship`(`ScholarshipID`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `ScholarshipApplication` ADD CONSTRAINT `ScholarshipApplication_ScholarshipID_fkey` FOREIGN KEY (`ScholarshipID`) REFERENCES `Scholarship`(`ScholarshipID`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `ScholarshipApplication` ADD CONSTRAINT `ScholarshipApplication_UserID_fkey` FOREIGN KEY (`UserID`) REFERENCES `User`(`UserID`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `ScholarshipSubmission` ADD CONSTRAINT `ScholarshipSubmission_ApplicationID_fkey` FOREIGN KEY (`ApplicationID`) REFERENCES `ScholarshipApplication`(`ApplicationID`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `ScholarshipSubmission` ADD CONSTRAINT `ScholarshipSubmission_RequirementID_fkey` FOREIGN KEY (`RequirementID`) REFERENCES `ScholarshipRequirement`(`RequirementID`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Welfare` ADD CONSTRAINT `Welfare_OfficerID_fkey` FOREIGN KEY (`OfficerID`) REFERENCES `Officer`(`OfficerID`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Hospital` ADD CONSTRAINT `Hospital_OfficerID_fkey` FOREIGN KEY (`OfficerID`) REFERENCES `Officer`(`OfficerID`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Post` ADD CONSTRAINT `Post_OfficerID_fkey` FOREIGN KEY (`OfficerID`) REFERENCES `Officer`(`OfficerID`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `PostPicture` ADD CONSTRAINT `PostPicture_PostID_fkey` FOREIGN KEY (`PostID`) REFERENCES `Post`(`PostID`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `PostComment` ADD CONSTRAINT `PostComment_PostID_fkey` FOREIGN KEY (`PostID`) REFERENCES `Post`(`PostID`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `PostComment` ADD CONSTRAINT `PostComment_UserID_fkey` FOREIGN KEY (`UserID`) REFERENCES `User`(`UserID`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `PostVisibility` ADD CONSTRAINT `PostVisibility_PostID_fkey` FOREIGN KEY (`PostID`) REFERENCES `Post`(`PostID`) ON DELETE CASCADE ON UPDATE CASCADE;
