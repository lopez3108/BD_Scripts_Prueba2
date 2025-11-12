SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--CREATEDBY: JOHAN
--CREATEDON: 1-11-23
--USO: VERIFICA BATCH Y AGENCYID COMBINATION
CREATE PROCEDURE [dbo].[sp_VerifyBatchNumberAndAgency] (@AgencyId INT,
@Batch VARCHAR(30),@PaymentChecksAgentToAgentId INT = null
)
AS

BEGIN
  IF EXISTS (SELECT TOP 1
        providerBatch
      FROM PaymentChecksAgentToAgent pcata
      WHERE pcata.FromAgency = @AgencyId
      AND pcata.providerBatch = @Batch AND pcata.PaymentChecksAgentToAgentId <> @PaymentChecksAgentToAgentId OR @PaymentChecksAgentToAgentId is null)
  BEGIN
    SELECT TOP 1
      t.providerBatch
     ,t.FromAgency
     ,a.Code + ' - ' + a.Name AS Agency
    FROM PaymentChecksAgentToAgent t
    INNER JOIN Agencies a
      ON t.FromAgency = a.AgencyId
    WHERE t.FromAgency = @AgencyId
    AND t.providerBatch = @Batch
  END
END;




GO