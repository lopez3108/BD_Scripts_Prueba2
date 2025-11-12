SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Created by jt/25-07-2024 Save  a new EmployeeVacationsAccumulated
CREATE PROCEDURE [dbo].[sp_SaveEmployeeVacationsAccumulated] (@EmployeeVacationsAccumulatedId INT = NULL,
@UserId INT,
@Hours DECIMAL(18, 2), -- Hours accumulated
@CreationDate DATETIME =NULL,
@CreatedBy INT,
@CycleDateVacation DATE = NULL,
@IdCreated INT OUTPUT)

AS

  IF (@EmployeeVacationsAccumulatedId IS NULL)
  BEGIN
    INSERT INTO [dbo].EmployeeVacationsAccumulated (UserId, Hours, CreationDate, CreatedBy, CycleDateVacation)
      VALUES (@UserId, @Hours, @CreationDate, @CreatedBy, @CycleDateVacation);
    SET @IdCreated = @@IDENTITY;

  END;
  ELSE
  BEGIN
    UPDATE [dbo].EmployeeVacationsAccumulated
    SET 
--    UserId = @UserId
       Hours = @Hours
--       ,CreationDate = @CreationDate
--       ,CreatedBy = @CreatedBy
--       ,CycleDateVacation = @CycleDateVacation
    WHERE EmployeeVacationsAccumulatedId = @EmployeeVacationsAccumulatedId;
    SET @IdCreated = @EmployeeVacationsAccumulatedId;

  END;
GO