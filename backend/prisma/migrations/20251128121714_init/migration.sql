/*
  Warnings:

  - The values [helthcare] on the enum `Welfare_WelfareType` will be removed. If these variants are still used in the database, this will fail.
  - Added the required column `NotificationTargetType` to the `Notification` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE `activity` DROP FOREIGN KEY `Activity_ActivityPortID_fkey`;

-- DropForeignKey
ALTER TABLE `activityevidence` DROP FOREIGN KEY `ActivityEvidence_ActivityID_fkey`;

-- DropForeignKey
ALTER TABLE `scholarshipapplication` DROP FOREIGN KEY `ScholarshipApplication_ScholarshipID_fkey`;

-- DropForeignKey
ALTER TABLE `scholarshiprequirement` DROP FOREIGN KEY `ScholarshipRequirement_ScholarshipID_fkey`;

-- DropForeignKey
ALTER TABLE `scholarshipsubmission` DROP FOREIGN KEY `ScholarshipSubmission_ApplicationID_fkey`;

-- DropForeignKey
ALTER TABLE `scholarshipsubmission` DROP FOREIGN KEY `ScholarshipSubmission_RequirementID_fkey`;

-- DropIndex
DROP INDEX `Activity_ActivityPortID_fkey` ON `activity`;

-- DropIndex
DROP INDEX `ActivityEvidence_ActivityID_fkey` ON `activityevidence`;

-- DropIndex
DROP INDEX `ScholarshipApplication_ScholarshipID_fkey` ON `scholarshipapplication`;

-- DropIndex
DROP INDEX `ScholarshipRequirement_ScholarshipID_fkey` ON `scholarshiprequirement`;

-- DropIndex
DROP INDEX `ScholarshipSubmission_ApplicationID_fkey` ON `scholarshipsubmission`;

-- DropIndex
DROP INDEX `ScholarshipSubmission_RequirementID_fkey` ON `scholarshipsubmission`;

-- AlterTable
ALTER TABLE `notification` ADD COLUMN `NotificationTargetType` ENUM('USER', 'ROLE', 'SECTION', 'SUBJECT') NOT NULL,
    ADD COLUMN `TargetID` INTEGER NULL;

-- AlterTable
ALTER TABLE `welfare` MODIFY `WelfareType` ENUM('registercourse', 'healthcare', 'scholarship', 'petition') NULL;

-- AddForeignKey
ALTER TABLE `Activity` ADD CONSTRAINT `Activity_ActivityPortID_fkey` FOREIGN KEY (`ActivityPortID`) REFERENCES `ActivityPort`(`ActivityPortID`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `ActivityEvidence` ADD CONSTRAINT `ActivityEvidence_ActivityID_fkey` FOREIGN KEY (`ActivityID`) REFERENCES `Activity`(`ActivityID`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `ScholarshipRequirement` ADD CONSTRAINT `ScholarshipRequirement_ScholarshipID_fkey` FOREIGN KEY (`ScholarshipID`) REFERENCES `Scholarship`(`ScholarshipID`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `ScholarshipApplication` ADD CONSTRAINT `ScholarshipApplication_ScholarshipID_fkey` FOREIGN KEY (`ScholarshipID`) REFERENCES `Scholarship`(`ScholarshipID`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `ScholarshipSubmission` ADD CONSTRAINT `ScholarshipSubmission_ApplicationID_fkey` FOREIGN KEY (`ApplicationID`) REFERENCES `ScholarshipApplication`(`ApplicationID`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `ScholarshipSubmission` ADD CONSTRAINT `ScholarshipSubmission_RequirementID_fkey` FOREIGN KEY (`RequirementID`) REFERENCES `ScholarshipRequirement`(`RequirementID`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `PostComment` ADD CONSTRAINT `PostComment_Parent_comment_fkey` FOREIGN KEY (`Parent_comment`) REFERENCES `PostComment`(`CommentID`) ON DELETE CASCADE ON UPDATE CASCADE;
