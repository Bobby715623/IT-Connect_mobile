/*
  Warnings:

  - You are about to drop the column `NotificationTargetType` on the `notification` table. All the data in the column will be lost.
  - You are about to drop the column `TargetID` on the `notification` table. All the data in the column will be lost.
  - You are about to drop the column `TargetType` on the `post` table. All the data in the column will be lost.
  - You are about to drop the `postvisibility` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE `postvisibility` DROP FOREIGN KEY `PostVisibility_PostID_fkey`;

-- AlterTable
ALTER TABLE `notification` DROP COLUMN `NotificationTargetType`,
    DROP COLUMN `TargetID`;

-- AlterTable
ALTER TABLE `post` DROP COLUMN `TargetType`,
    ADD COLUMN `Visibility` ENUM('PUBLIC', 'SPECIFIC') NOT NULL DEFAULT 'PUBLIC',
    MODIFY `IsPinned` BOOLEAN NULL DEFAULT false,
    MODIFY `NotifyType` ENUM('urgent', 'schedule', 'normal', 'silent') NULL,
    MODIFY `CreateDate` DATETIME(3) NULL DEFAULT CURRENT_TIMESTAMP(3),
    MODIFY `CanComment` BOOLEAN NULL DEFAULT true;

-- AlterTable
ALTER TABLE `postcomment` MODIFY `Comment_at` DATETIME(3) NULL DEFAULT CURRENT_TIMESTAMP(3);

-- DropTable
DROP TABLE `postvisibility`;

-- CreateTable
CREATE TABLE `PostTarget` (
    `PostTargetID` INTEGER NOT NULL AUTO_INCREMENT,
    `PostID` INTEGER NOT NULL,
    `TargetType` ENUM('USER', 'SECTION', 'SUBJECT', 'MAJOR', 'YEAR_LEVEL', 'SCHOLARSHIP_STAR', 'ACTIVITY_STAR', 'ACTIVITY_FOLLOWER', 'SCHOLARSHIP_APPLICANT', 'YEAR_MAJOR') NOT NULL,
    `TargetID` INTEGER NULL,
    `TargetExtraID` INTEGER NULL,

    PRIMARY KEY (`PostTargetID`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `PostTarget` ADD CONSTRAINT `PostTarget_PostID_fkey` FOREIGN KEY (`PostID`) REFERENCES `Post`(`PostID`) ON DELETE CASCADE ON UPDATE CASCADE;
