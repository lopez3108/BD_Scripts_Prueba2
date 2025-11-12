SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--CREATED BY: JOHAN
--CREATED ON: 18-4-2023
--GUARDA INFORMACION PARA EMPLOYEEWARNING
CREATE PROCEDURE [dbo].[sp_CreateEmployeeWarning] @EmployeeWarningId INT = NULL,

@CreationDate DATETIME,
@UserId INT,
@Name VARCHAR(150),
@CreatedBy INT,
--@LastUpdatedOn DATETIME,
--@LastUpdatedBy INT,
@IdCreated INT OUTPUT
AS
BEGIN


  IF (@EmployeeWarningId IS NULL)
  BEGIN
    INSERT INTO dbo.EmployeeWarning (CreationDate, UserId, Name, CreatedBy)
      VALUES (@CreationDate, @UserId, @Name, @CreatedBy)
    SET @IdCreated = @@identity;


  END
  ELSE
  BEGIN


    BEGIN
      UPDATE dbo.EmployeeWarning
      SET CreatedBy = @CreatedBy
         ,UserId = @UserId        
         ,Name = @Name
--         LastUpdatedOn =@LastUpdatedOn,
--         LastUpdatedBy = @LastUpdatedBy

      WHERE EmployeeWarningId = @EmployeeWarningId
      SET @IdCreated = @EmployeeWarningId;

    END

  END
END
GO