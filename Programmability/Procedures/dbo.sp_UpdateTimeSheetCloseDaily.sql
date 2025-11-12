SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Updated by Carlos Bermuedez task 5407
--Updated by Felipe oquendo task 5494 date 28-11-2023
--Updated by Felipe oquendo task 6395 date 21-03-2025
CREATE PROCEDURE [dbo].[sp_UpdateTimeSheetCloseDaily] @CashierId INT, @CreationDate DATETIME = NULL, @ClosedOn DATETIME = NULL, @IsCashier BIT, @LastUpdatedOn DATETIME = NULL, @LastUpdatedBy INT = NULL, @AgencyId INT, @StatusCode VARCHAR(10), @ApprovedOn DATETIME = NULL, @ApprovedBy INT = NULL, @PreApproved BIT = NULL
AS


BEGIN

  DECLARE @StatusId INT = NULL;
  DECLARE @RolCashier INT = NULL;
  SET @RolCashier = (SELECT
      UsertTypeId
    FROM UserTypes
    WHERE Code = 'Cashier')

  IF (@StatusCode IS NOT NULL)
  BEGIN
    SET @StatusId = (SELECT
        Id
      FROM TimeSheetStatus
      WHERE Code = @StatusCode)
  END

  DECLARE @UserId INT;
  SET @UserId = (SELECT TOP 1
      UserId
    FROM Cashiers
    WHERE CashierId = @CashierId);

  -- Set logout for the cashier by cashier (CIERRE DEL DAILY CAJERO)
  -- Set logout for the cashier by admin (CIERRE DESDEL DAILY DETAILS ADMIN)

  UPDATE TimeSheet--Update only the status 
  SET 
--  LogoutDate = @ClosedOn  // se comento por la task 6395 NO debe de actualizar acá ya que acá esta actualizando
--  sin importar si tiene LogoutDate o no y nos interesa es que actualice solo cuando LogoutDate is null lo hacemos 
-- en la parte de abajo 
     LastUpdatedOn = @LastUpdatedOn
     ,LastUpdatedBy = @LastUpdatedBy
     ,StatusId = @StatusId
     ,
      --			  ApprovedOn = @ApprovedOn,
      ApprovedOn =
      CASE
        WHEN Rol = @RolCashier THEN @ApprovedOn
        ELSE NULL
      END
     ,ApprovedBy = @ApprovedBy
     ,PreApproved =--PreApproved mean approved by the system
      CASE
        WHEN Rol = @RolCashier THEN @PreApproved
        ELSE NULL
      END
  WHERE UserId = @UserId
  AND CAST(LoginDate AS DATE) = CAST(@CreationDate AS DATE)
  AND (AgencyId = @AgencyId
  OR AgencyId IS NULL)
--AND LogoutDate IS NULL;

UPDATE TimeSheet--Update only the logout date --por la task 6395 
  SET LogoutDate = @ClosedOn
  WHERE UserId = @UserId
  AND CAST(LoginDate AS DATE) = CAST(@CreationDate AS DATE)
  AND (AgencyId = @AgencyId
  OR AgencyId IS NULL)
AND LogoutDate IS NULL;
END
GO