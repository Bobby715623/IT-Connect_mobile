/*
  Warnings:

  - You are about to drop the column `photoulr` on the `hospital` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE `hospital` DROP COLUMN `photoulr`,
    ADD COLUMN `photourl` VARCHAR(191) NULL;
