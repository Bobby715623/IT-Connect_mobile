/*
  Warnings:

  - You are about to drop the column `WelfareDocument` on the `welfare` table. All the data in the column will be lost.
  - You are about to drop the column `WelfareGuide` on the `welfare` table. All the data in the column will be lost.
  - You are about to drop the column `WelfareTitle` on the `welfare` table. All the data in the column will be lost.
  - A unique constraint covering the columns `[WelfareType]` on the table `Welfare` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `Title` to the `Welfare` table without a default value. This is not possible if the table is not empty.
  - Made the column `WelfareType` on table `welfare` required. This step will fail if there are existing NULL values in that column.

*/
-- AlterTable
ALTER TABLE `welfare` DROP COLUMN `WelfareDocument`,
    DROP COLUMN `WelfareGuide`,
    DROP COLUMN `WelfareTitle`,
    ADD COLUMN `CoverImage` VARCHAR(191) NULL,
    ADD COLUMN `Title` VARCHAR(191) NOT NULL,
    MODIFY `WelfareType` ENUM('registercourse', 'healthcare', 'scholarship', 'petition') NOT NULL;

-- CreateTable
CREATE TABLE `WelfareFile` (
    `WelfareFileID` INTEGER NOT NULL AUTO_INCREMENT,
    `FileName` VARCHAR(191) NOT NULL,
    `FileUrl` VARCHAR(191) NOT NULL,
    `FileType` VARCHAR(191) NULL,
    `WelfareID` INTEGER NOT NULL,

    PRIMARY KEY (`WelfareFileID`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateIndex
CREATE UNIQUE INDEX `Welfare_WelfareType_key` ON `Welfare`(`WelfareType`);

-- AddForeignKey
ALTER TABLE `WelfareFile` ADD CONSTRAINT `WelfareFile_WelfareID_fkey` FOREIGN KEY (`WelfareID`) REFERENCES `Welfare`(`WelfareID`) ON DELETE RESTRICT ON UPDATE CASCADE;
