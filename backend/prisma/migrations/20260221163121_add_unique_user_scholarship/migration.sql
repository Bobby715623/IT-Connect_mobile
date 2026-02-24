/*
  Warnings:

  - A unique constraint covering the columns `[UserID,ScholarshipID]` on the table `ScholarshipApplication` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateIndex
CREATE UNIQUE INDEX `ScholarshipApplication_UserID_ScholarshipID_key` ON `ScholarshipApplication`(`UserID`, `ScholarshipID`);
