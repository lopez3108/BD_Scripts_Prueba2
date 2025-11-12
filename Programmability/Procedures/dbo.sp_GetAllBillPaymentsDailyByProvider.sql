SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllBillPaymentsDailyByProvider]
(@Creationdate DATE = NULL,
 @AgencyId     INT,
 @CreatedBy    INT,
 @ProviderId   INT  = NULL
)
AS
     BEGIN
         SELECT 
	    --p.ProviderId,
     --           p.Name,
     --           p.Active,
     --           p.ProviderTypeId,
     --           p.AcceptNegative,
     --           CAST(1 AS BIT) AS Disabled,
     --           CAST(0 AS BIT) AS AcceptZero,
     --           0 Comision,
     --           pt.Code AS ProviderTypeCode,
     --           pt.Description AS ProviderType,
     --           0 transactions,
         B.BillPaymentId,
         ISNULL(b.USD, 0) USD,
         ISNULL(b.Commission, 0) Commission,
		 b.LastUpdatedOn,
         usu.Name LastUpdatedByName,
		 usu.UserId LastUpdatedBy,
		 b.DetailedTransaction
         FROM BillPayments b
		 LEFT JOIN Users usu ON b.LastUpdatedBy = usu.UserId
         WHERE b.AgencyId = @AgencyId
               AND (CAST(b.CreationDate AS DATE) = CAST(@CreationDate AS DATE))
               AND b.CreatedBy = @CreatedBy
               AND b.ProviderId = @ProviderId;
     END;
GO