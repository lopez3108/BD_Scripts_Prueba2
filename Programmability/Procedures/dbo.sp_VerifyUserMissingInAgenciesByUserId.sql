SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--CREATEDBY: JOHAN
--CREATEDON: 07-12-2023
--USO: MISSING DEL CAJERO A INACTIVAR

--UpdateBY: Felipe oquendo 
--UpdateOn: 18-12-2023
--task: 5570 No permitir desvincular cajeros de alguna agencia con missing payment(pending)
--Adiciono nuevo parametro AgencyId
-- 2025-07-15 JT/6603: Missing payments managers

CREATE PROCEDURE [dbo].[sp_VerifyUserMissingInAgenciesByUserId] (@UserId INT, @AgencyId int = NULL)
AS

BEGIN

  DECLARE @CashierId INT;
  SET @CashierId = (SELECT
      c.CashierId
    FROM dbo.Cashiers c
    WHERE c.UserId = @UserId)
    SELECT
      [dbo].FN_GeneratependingMissing(@AgencyId, NULL, @CashierId, NULL) AS Missing  

END


GO