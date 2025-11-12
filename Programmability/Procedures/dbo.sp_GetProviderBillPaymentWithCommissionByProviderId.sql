SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetProviderBillPaymentWithCommissionByProviderId]
(@Creationdate DATE = NULL,
 @AgencyId     INT,
  @ProviderId    INT
)
AS
     BEGIN
         DECLARE @MonthDate INT= CAST(MONTH(@Creationdate) AS INT);
         DECLARE @YearDate INT= CAST(YEAR(@Creationdate) AS INT);
         SELECT TOP 1 p.ProviderId,
                p.Name,
                p.Active,
                p.ProviderTypeId,
                p.AcceptNegative,
                'true' AS 'Disabled',
                0 Comision,
                pt.Code AS ProviderTypeCode,
                pt.Description AS ProviderType,
            
                --B.BillPaymentId,
                ISNULL(pc.ProviderCommissionPaymentId, 0) ProviderCommissionPaymentId
         FROM Providers p
              INNER JOIN ProviderTypes pt ON p.ProviderTypeId = pt.ProviderTypeId
                                             AND P.Active = 1
              INNER JOIN ProviderCommissionPayments pc ON pc.ProviderId = p.ProviderId
                                                         AND (pc.Year = @YearDate
                                                              AND pc.Month = @MonthDate)
                                                         AND pc.AgencyId = @AgencyId
              --LEFT JOIN BillPayments b ON b.ProviderId = p.ProviderId
              --                            AND b.AgencyId = @AgencyId
              --                            AND (CAST(b.CreationDate AS DATE) = CAST(@CreationDate AS DATE))
              --                            AND b.CreatedBy = @CreatedBy
         WHERE pt.Code = 'C01' AND p.ProviderId = @ProviderId
         ORDER BY p.Name;
     END;

GO