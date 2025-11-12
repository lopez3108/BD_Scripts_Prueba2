SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--CREATEDBY: JOHAN
--CREATEDON: 10-12-2023
--USO: MISSING DEL CAJERO PENDIENTE
--UPDATEDBY: ROMARIO
--CREATEDON: 16-12-2023
--USO: MISSING DEL CAJERO PENDIENTE

-- 2025-07-15 JT/6603: Missing payments managers

CREATE PROCEDURE [dbo].[sp_GetPendingMissing] (@AgencyId INT = NULL,
@StartingDate DATETIME = NULL,
@EndingDate DATETIME = NULL,
@UserId INT,
@UserManagerId INT = NULL)
AS

BEGIN
  DECLARE @CashierId INT;
  SET @CashierId = (SELECT
      c.CashierId
    FROM dbo.Cashiers c
    WHERE c.UserId = @UserId)

  SELECT
    [dbo].FN_GeneratependingMissing(@AgencyId, @StartingDate, @CashierId, @UserManagerId) AS Missing


END





GO