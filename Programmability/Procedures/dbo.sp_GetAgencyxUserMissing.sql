SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--CREATEDBY: FELIPE
--CREATEDON: 27-12-2023
--USO: MISSING DEL CAJERO PENDIENTE * AGENCIA
-- 2025-07-15 JT/6603: Missing payments managers

CREATE PROCEDURE [dbo].[sp_GetAgencyxUserMissing] (
@AgencyId INT = NULL, 
@CashierId int = NULL)
AS

BEGIN

 IF (((select [dbo].FN_GeneratependingMissing(@AgencyId, null, @CashierId, NULL)) > 0)
    )
  BEGIN
    SELECT
      -7; --Error Already has pending missing
  END;

  ELSE

  BEGIN
    SELECT
      0; --Error Already has pending missing
  END;
  --Error Already has pending missing  END;

END




GO