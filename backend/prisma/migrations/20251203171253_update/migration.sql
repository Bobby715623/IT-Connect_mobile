-- AlterTable
ALTER TABLE `activityport` ADD COLUMN `ScholarshipID` INTEGER NULL;

-- AlterTable
ALTER TABLE `scholarship` ADD COLUMN `ActivityHourNeeded` INTEGER NULL DEFAULT 0;

-- AddForeignKey
ALTER TABLE `ActivityPort` ADD CONSTRAINT `ActivityPort_ScholarshipID_fkey` FOREIGN KEY (`ScholarshipID`) REFERENCES `Scholarship`(`ScholarshipID`) ON DELETE SET NULL ON UPDATE CASCADE;
