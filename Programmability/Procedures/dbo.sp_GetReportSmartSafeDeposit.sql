SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReportSmartSafeDeposit]
(@AgencyId   INT,
 @FromDate   DATETIME = NULL,
 @ToDate     DATETIME = NULL,
 @Date       DATETIME,
 @ProviderId INT
)
AS
     BEGIN
         IF(@FromDate IS NULL)
             BEGIN
                 SET @FromDate = DATEADD(day, -10, @Date);
                 SET @ToDate = @Date;
         END;
        


select 
                       'SMART SAFE DEPOSIT' AS Type,
					   s.CreationDate,
                       'SMART SAFE DEPOSIT ID ' + s.TransactionId  as Description,
                      ABS(s.Usd) Usd,
					   u.Name as Employee
from SmartSafeDeposit s
INNER JOIN dbo.Users u ON u.UserId = s.UserId
WHERE 
						s.AgencyId = @AgencyId
                      AND ProviderId = @ProviderId
                      AND CAST(s.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
                      AND CAST(s.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
					  ORDER BY s.CreationDate ASC


     END;
GO