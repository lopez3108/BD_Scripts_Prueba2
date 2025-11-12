SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- Create: Felipe
-- Date: 30-Enero-2024
-- Task 5550  CASH ADVANCE OR BACK SENT 11-28-2023
CREATE PROCEDURE [dbo].[sp_GetAllCashAdvanceByDate]
(@From      DATE,
 @To        DATE,
 @AgencyId  INT,
 @CreatedBy INT
)
AS
     BEGIN
         SELECT CAST(dbo.CashAdvanceOrBack.CreationDate AS DATE) AS Date,
                SUM(ISNULL(dbo.CashAdvanceOrBack.USD, 0)) USD,
		
                dbo.Providers.Name+' (C.A.B)' Name,
                dbo.CashAdvanceOrBack.AgencyId
         FROM dbo.CashAdvanceOrBack 
              INNER JOIN dbo.Providers ON dbo.CashAdvanceOrBack.ProviderId = dbo.Providers.ProviderId
         WHERE 
         CAST(dbo.CashAdvanceOrBack.CreationDate AS DATE) >= CAST(@From AS DATE)
               AND CAST(dbo.CashAdvanceOrBack.CreationDate AS DATE) <= CAST(@To AS DATE)
               AND dbo.CashAdvanceOrBack.CreatedBy = @CreatedBy
               AND dbo.CashAdvanceOrBack.AgencyId = @AgencyId
              
               AND 
               UseCashAdvanceOrBack = 1

         GROUP BY  CAST(dbo.CashAdvanceOrBack.CreationDate AS DATE),
                  dbo.Providers.Name,
                  dbo.CashAdvanceOrBack.AgencyId,
                  dbo.CashAdvanceOrBack.ProviderId;
     END;


GO