SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllBillPaymentsDaily]
(@Creationdate DATE = NULL,
 @AgencyId     INT,
 @CreatedBy    INT,
 @Active BIT = NULL
)
AS
     BEGIN
         DECLARE @MonthDate INT= CAST(MONTH(@Creationdate) AS INT);
         DECLARE @YearDate INT= CAST(YEAR(@Creationdate) AS INT);
         SELECT p.ProviderId,
                p.Name,
                p.Active,
                p.ProviderTypeId,
                p.AcceptNegative,
                0 Comision,
                pt.Code AS ProviderTypeCode,
                pt.Description AS ProviderType,
                0 transactions,
                CASE
                    WHEN b.Commission > 0
                    THEN b.USD + ISNULL(b.Commission,0)
                    ELSE ISNULL(b.USD, '0.00')
                END AS moneyvalue,
			 b.USD,
                CAST(1 AS BIT) AS 'Set',
			 --'false' AS Valid,
                B.BillPaymentId,
                b.Commission,
                p.CostAndCommission,
			 p.DetailedTransaction
         FROM Providers p
              INNER JOIN ProviderTypes pt ON p.ProviderTypeId = pt.ProviderTypeId
                                             AND P.Active = 1            
              LEFT JOIN BillPayments b ON b.ProviderId = p.ProviderId
                                          AND b.AgencyId = @AgencyId
                                          AND (CAST(b.CreationDate AS DATE) = CAST(@CreationDate AS DATE))
                                          AND b.CreatedBy = @CreatedBy
         WHERE pt.Code = 'C01'  AND ( p.Active=@Active OR @Active IS NULL)
         ORDER BY p.Name;
     END;
GO