SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Created by jt/15-06-2025  Add new module LEAVE HOURS


CREATE PROCEDURE [dbo].[sp_CreateLeaveHour] (@EmployeeLeaveHoursId INT = NULL,
@UserId INT,
@Hours DECIMAL(18, 2), -- Hours accumulated
@CreationDate DATETIME = NULL,
@CreatedBy INT = NULL,
@CycleDateLeaveHours DATE = NULL,
@FileName varchar(1000) = NULL,
@IdCreated INT OUTPUT)
AS
  IF (@EmployeeLeaveHoursId IS NULL)
  BEGIN
    IF (@CycleDateLeaveHours IS NULL)
    BEGIN
      SELECT --ALWAY WE NEED TO KNOW THE CURRENT CYCLE
        @CycleDateLeaveHours = CycleDateLeaveHours
      FROM Cashiers c
      WHERE c.UserId = @UserId
    END
    INSERT INTO [dbo].EmployeeLeaveHours (UserId, Hours, CreationDate, CreatedBy, CycleDateLeaveHours,FileName)
      VALUES (@UserId, @Hours, @CreationDate, @CreatedBy, @CycleDateLeaveHours,@FileName);
    SET @IdCreated = @@IDENTITY;
  END;
  ELSE
  BEGIN
    UPDATE [dbo].EmployeeLeaveHours
    SET
    Hours = @Hours
    WHERE EmployeeLeaveHoursId = @EmployeeLeaveHoursId;
    SET @IdCreated = @EmployeeLeaveHoursId;
  END;
GO