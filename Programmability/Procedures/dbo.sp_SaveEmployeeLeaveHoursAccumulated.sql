SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Created by jt/15-06-2025  Add new module LEAVE HOURS
CREATE PROCEDURE [dbo].[sp_SaveEmployeeLeaveHoursAccumulated] (@EmployeeLeaveHoursAccumulatedId INT = NULL,
@UserId INT,
@Hours DECIMAL(18, 2), -- Hours accumulated
@CreationDate DATETIME =NULL,
@CreatedBy INT,
@CycleDateLeaveHours DATE = NULL,
@IdCreated INT OUTPUT)

AS

  IF (@EmployeeLeaveHoursAccumulatedId IS NULL)
  BEGIN
    INSERT INTO [dbo].EmployeeLeaveHoursAccumulated (UserId, Hours, CreationDate, CreatedBy, CycleDateLeaveHours)
      VALUES (@UserId, @Hours, @CreationDate, @CreatedBy, @CycleDateLeaveHours);
    SET @IdCreated = @@IDENTITY;

  END;
  ELSE
  BEGIN
    UPDATE [dbo].EmployeeLeaveHoursAccumulated
    SET 
--    UserId = @UserId
       Hours = @Hours
--       ,CreationDate = @CreationDate
--       ,CreatedBy = @CreatedBy
--       ,CycleDateVacation = @CycleDateVacation
    WHERE EmployeeLeaveHoursAccumulatedId = @EmployeeLeaveHoursAccumulatedId;
    SET @IdCreated = @EmployeeLeaveHoursAccumulatedId;

  END;
GO