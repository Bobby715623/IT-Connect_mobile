/*
  Warnings:

  - The values [Wendesday] on the enum `Subject_Sec_StudyTime` will be removed. If these variants are still used in the database, this will fail.
  - A unique constraint covering the columns `[LineUserID]` on the table `User` will be added. If there are existing duplicate values, this will fail.

*/
-- DropForeignKey
ALTER TABLE `follow_activitypost` DROP FOREIGN KEY `Follow_ActivityPost_ActivityPostID_fkey`;

-- DropForeignKey
ALTER TABLE `subject_sec` DROP FOREIGN KEY `Subject_Sec_SubjectID_fkey`;

-- DropIndex
DROP INDEX `Follow_ActivityPost_ActivityPostID_fkey` ON `follow_activitypost`;

-- DropIndex
DROP INDEX `Subject_Sec_SubjectID_fkey` ON `subject_sec`;

-- AlterTable
ALTER TABLE `activity` ADD COLUMN `RelatedPostID` INTEGER NULL,
    MODIFY `Status` ENUM('waitforprocess', 'approve', 'reject') NULL DEFAULT 'waitforprocess';

-- AlterTable
ALTER TABLE `activitypost` ADD COLUMN `Picture` VARCHAR(191) NULL;

-- AlterTable
ALTER TABLE `notification` MODIFY `IsSent` BOOLEAN NULL DEFAULT false;

-- AlterTable
ALTER TABLE `post` MODIFY `Content` TEXT NULL;

-- AlterTable
ALTER TABLE `scholarship` ADD COLUMN `ActivityDeadline` DATETIME(3) NULL,
    ADD COLUMN `Interviewplace` VARCHAR(191) NULL;

-- AlterTable
ALTER TABLE `student` ADD COLUMN `Branch` ENUM('MULTIMEDIA', 'NETWORK', 'SOFTWARE') NULL,
    ADD COLUMN `Major` ENUM('IT', 'BIT', 'AIT', 'DSBA') NULL;

-- AlterTable
ALTER TABLE `subject_sec` MODIFY `StudyTime` ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') NULL;

-- AlterTable
ALTER TABLE `user` ADD COLUMN `FCMToken` VARCHAR(191) NULL,
    ADD COLUMN `LineUserID` VARCHAR(191) NULL;

-- CreateTable
CREATE TABLE `AcademicCalendar` (
    `ID` INTEGER NOT NULL AUTO_INCREMENT,
    `AcademicYear` INTEGER NOT NULL,
    `Semester` INTEGER NOT NULL,
    `Title` VARCHAR(191) NOT NULL,
    `EventType` ENUM('TERM_START', 'PRE_REGISTRATION', 'ANNOUNCE_PRE_REGIS', 'REGISTRATION', 'PAYMENT_NO_FINE', 'PAYMENT_WITH_FINE', 'LATE_REGISTRATION', 'PAYMENT_LATE_REGIS', 'ADD_CHANGE_SUBJECT', 'WITHDRAW_SUBJECT', 'MIDTERM_EXAM', 'TEACHER_EVALUATION', 'LEAVE_DEADLINE', 'CLASS_END', 'FINAL_EXAM', 'GRADUATE_EXAM', 'TERM_END', 'GRADE_SUBMISSION', 'SPECIAL_OPEN_REQ') NOT NULL,
    `StartDate` DATETIME(3) NOT NULL,
    `EndDate` DATETIME(3) NULL,
    `Description` VARCHAR(191) NULL,
    `IsProcessed` BOOLEAN NOT NULL DEFAULT false,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    PRIMARY KEY (`ID`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateIndex
CREATE UNIQUE INDEX `User_LineUserID_key` ON `User`(`LineUserID`);

-- AddForeignKey
ALTER TABLE `Subject_Sec` ADD CONSTRAINT `Subject_Sec_SubjectID_fkey` FOREIGN KEY (`SubjectID`) REFERENCES `Subject`(`SubjectID`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Activity` ADD CONSTRAINT `Activity_RelatedPostID_fkey` FOREIGN KEY (`RelatedPostID`) REFERENCES `ActivityPost`(`ActivityPostID`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Follow_ActivityPost` ADD CONSTRAINT `Follow_ActivityPost_ActivityPostID_fkey` FOREIGN KEY (`ActivityPostID`) REFERENCES `ActivityPost`(`ActivityPostID`) ON DELETE CASCADE ON UPDATE CASCADE;
