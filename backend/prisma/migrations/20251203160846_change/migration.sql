-- AlterTable
ALTER TABLE `activityport` ADD COLUMN `status` ENUM('active', 'expired', 'completed') NULL;
