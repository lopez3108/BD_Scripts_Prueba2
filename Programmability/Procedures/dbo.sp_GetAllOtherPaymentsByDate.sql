SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllOtherPaymentsByDate]
(@From      DATE,
 @To        DATE,
 @AgencyId  INT,
 @CreatedBy INT
)
AS
     BEGIN
         SELECT isnull(SUM(dbo.OtherPayments.Usd ) ,0) + ISNULL(sum(dbo.OtherPayments.UsdPayMissing),0) AS USD,
                CAST(dbo.OtherPayments.CreationDate AS DATE) AS Date,
                'OTHER PAYMENTS' AS Name
         FROM dbo.OtherPayments
         WHERE CAST(dbo.OtherPayments.CreationDate AS DATE) >= CAST(@From AS DATE)
               AND CAST(dbo.OtherPayments.CreationDate AS DATE) <= CAST(@To AS DATE)
               AND CreatedBy = @CreatedBy
               AND AgencyId = @AgencyId
         GROUP BY CAST(dbo.OtherPayments.CreationDate AS DATE);
     END;
GO