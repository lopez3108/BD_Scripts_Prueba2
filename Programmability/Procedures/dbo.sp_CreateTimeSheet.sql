SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Last update by JT/52-09-2025 Task 6206 Validación tiempos repetidos
CREATE PROCEDURE [dbo].[sp_CreateTimeSheet] (@UserId INT,
@LoginDate DATETIME,
@AgencyId INT = NULL,
@CashierId INT = NULL,
@EstimatedDepartureTime TIME = NULL,
@Rol VARCHAR(20))
AS

  DECLARE @RolId INT;
  SET @RolId = (SELECT
      ut.UsertTypeId
    FROM UserTypes ut
    WHERE ut.Code = @Rol)

  BEGIN
    IF NOT EXISTS (SELECT --First we need to validate that the record is not repeated.
          1
        FROM [dbo].[TimeSheet]
        WHERE UserId = @UserId
        AND LoginDate = @LoginDate)
    BEGIN
      INSERT INTO [dbo].[TimeSheet] ([UserId],
      [LoginDate],
      [AgencyId],
      [EstimatedDepartureTime], Rol)
        VALUES (@UserId, @LoginDate, @AgencyId, @EstimatedDepartureTime, @RolId);
    END


    IF (@AgencyId IS NOT NULL)--SOLO PARA CAJERO
    BEGIN
      IF NOT EXISTS (SELECT TOP 1--Verificamos si se necesita crear el daily para el cajero
            1
          FROM Daily
          WHERE @CashierId IS NOT NULL
          AND CashierId = @CashierId
          AND AgencyId = @AgencyId
          AND CAST(CreationDate AS DATE) = CAST(@LoginDate AS DATE))
      BEGIN
        INSERT INTO [dbo].[Daily] ([CashierId],
        [AgencyId],
        CreationDate)
          VALUES (@CashierId, @AgencyId, @LoginDate);
      END;

      --CIERRA LOS TIMESHEET PREVIOS A LA CREACION DEL TIMESHEET DEL CAJERO, QUE PERTEZCAN A UN ADMIN
      IF (EXISTS (SELECT
            1
          FROM TimeSheet
          WHERE UserId = @UserId
          AND CAST(LoginDate AS DATE) = CAST(@LoginDate AS DATE)
          AND AgencyId IS NULL
          AND LogoutDate IS NULL)
        )

      BEGIN

        UPDATE dbo.TimeSheet
        SET LogoutDate = @LoginDate
        WHERE UserId = @UserId
        AND CAST(LoginDate AS DATE) = CAST(@LoginDate AS DATE)
        AND AgencyId IS NULL
        AND LogoutDate IS NULL;
      END
    END;

    SELECT
      CAST(1 AS BIT);
  END;



GO