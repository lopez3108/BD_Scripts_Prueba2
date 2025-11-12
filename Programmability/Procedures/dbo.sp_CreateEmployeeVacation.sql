SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Created by jt/25-07-2024 Save  a new EmployeeVacationsAccumulated
-- date 21-05-2025 task 6487 MODULO SICK HOURS - ADJUSTMENT PAID SICK TIME JF

CREATE PROCEDURE [dbo].[sp_CreateEmployeeVacation] (@EmployeeVacationsId INT = NULL,
@UserId INT,
@Hours DECIMAL(18, 2), -- Hours accumulated
@CreationDate DATETIME = NULL,
@CreatedBy INT = NULL,
@CycleDateVacation DATE = NULL,
@FileName varchar(1000) = NULL,
@IdCreated INT OUTPUT)
AS
  IF (@EmployeeVacationsId IS NULL)
  BEGIN
    IF (@CycleDateVacation IS NULL)
    BEGIN
      SELECT --ALWAY WE NEED TO KNOW THE CURRENT CYCLE
        @CycleDateVacation = CycleDateVacation
      FROM Cashiers c
      WHERE c.UserId = @UserId
    END
    INSERT INTO [dbo].EmployeeVacations (UserId, Hours, CreationDate, CreatedBy, CycleDateVacation,FileName)
      VALUES (@UserId, @Hours, @CreationDate, @CreatedBy, @CycleDateVacation,@FileName);
    SET @IdCreated = @@IDENTITY;
  END;
  ELSE
  BEGIN
    UPDATE [dbo].EmployeeVacations
    SET
    --UserId = @UserId
    Hours = @Hours
    --,CreationDate = @CreationDate
    --,CreatedBy = @CreatedBy
    --,CycleDateVacation = @CycleDateVacationk
    WHERE EmployeeVacationsId = @EmployeeVacationsId;
    SET @IdCreated = @EmployeeVacationsId;
  END;

GO