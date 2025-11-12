SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--CREATEDBY: Romario
--CREATEDON: 18-01-2024
--USO: AGENCIA CON MISSING NO SE PUEDE INACTIVAR

CREATE PROCEDURE [dbo].[sp_GetAgencyxMissing] (
@AgencyId INT = NULL, 
@CashierId int = NULL)
AS

BEGIN

 IF (((select [dbo].FN_GeneratependingMissingByAgency(@AgencyId, null, @CashierId)) > 0)
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