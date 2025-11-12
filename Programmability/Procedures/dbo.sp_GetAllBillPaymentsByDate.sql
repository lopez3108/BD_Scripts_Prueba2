SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllBillPaymentsByDate]
(@From      DATE,
 @To        DATE,
 @AgencyId  INT,
 @CreatedBy INT
)
AS
     BEGIN
         SELECT dbo.BillPayments.CreationDate AS Date,
                --dbo.BillPayments.USD 
                ISNULL(ISNULL(SUM(dbo.BillPayments.USD), 0) + SUM(ISNULL(dbo.BillPayments.Commission, 0)), 0) AS USD,
                dbo.Providers.Name,
                dbo.BillPayments.AgencyId
         FROM dbo.BillPayments
              INNER JOIN dbo.Providers ON dbo.BillPayments.ProviderId = dbo.Providers.ProviderId
         WHERE CAST(dbo.BillPayments.CreationDate AS DATE) >= CAST(@From AS DATE)
               AND CAST(dbo.BillPayments.CreationDate AS DATE) <= CAST(@To AS DATE)
               AND CreatedBy = @CreatedBy
               AND AgencyId = @AgencyId
         GROUP BY dbo.BillPayments.CreationDate,
                  dbo.Providers.Name,
                  dbo.BillPayments.AgencyId;
     END;
GO