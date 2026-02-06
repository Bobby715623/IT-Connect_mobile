-- AlterTable
ALTER TABLE `hospital` ADD COLUMN `latitude` DOUBLE NULL,
    ADD COLUMN `longitude` DOUBLE NULL,
    ADD COLUMN `photoulr` VARCHAR(191) NULL,
    ADD COLUMN `province` VARCHAR(191) NULL;
