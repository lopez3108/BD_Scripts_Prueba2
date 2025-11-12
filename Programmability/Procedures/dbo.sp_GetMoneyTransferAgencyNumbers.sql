SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetMoneyTransferAgencyNumbers] @ProviderId INT = NULL
AS
BEGIN
  --SELECT a.Code+' - '+a.Name AS Agency,
  --       ISNULL(
  --             (
  --                 SELECT TOP 1 m.MoneyTransferxAgencyNumbersId
  --                 FROM dbo.MoneyTransferxAgencyNumbers m
  --                 WHERE ProviderId = @ProviderId
  --                       AND m.AgencyId = a.AgencyId
  --             ), 0) AS MoneyTransferxAgencyNumbersId,
  --       a.AgencyId,
  --       @ProviderId AS ProviderId,
  --       ISNULL(
  --             (
  --                 SELECT TOP 1 m.Number
  --                 FROM dbo.MoneyTransferxAgencyNumbers m
  --                 WHERE ProviderId = @ProviderId
  --                       AND m.AgencyId = a.AgencyId
  --             ), NULL) AS Number
  --FROM dbo.Agencies a;


  SELECT
    a.AgencyId
   ,a.Code + ' - ' + a.Name AS Agency
   ,Number,
   Number AS NumberSaved,

   @ProviderId AS ProviderId
  FROM dbo.Agencies a
  LEFT JOIN MoneyTransferxAgencyNumbers mt
    ON a.AgencyId = mt.AgencyId
      AND (mt.ProviderId = @ProviderId
        OR ProviderId IS NULL)
  WHERE a.IsActive = 1;
END;



GO