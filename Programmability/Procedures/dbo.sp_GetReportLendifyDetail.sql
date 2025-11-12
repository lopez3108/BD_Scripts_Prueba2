SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReportLendifyDetail]
(@AgencyId INT,
 @FromDate DATETIME = NULL,
 @ToDate   DATETIME = NULL,
 @Date     DATETIME
)
AS
     BEGIN
         IF(@FromDate IS NULL)
             BEGIN
                 SET @FromDate = DATEADD(day, -10, @Date);
                 SET @ToDate = @Date;
         END;
         SELECT l.AgencyId,
                CAST(l.AprovedDate AS DATE) AS Date,
                'APPROVED' AS Type,
                l.AprovedBy,
                l.Name AS Name,
                u.Name AS Cashier,
                u.UserId,
                ISNULL(l.ComissionCashier, 0) AS ComissionCashier,
				ISNULL(l.CommissionAgency, 0) AS CommissionAgency,
                u.UserId
         FROM Lendify l
              INNER JOIN Users u ON u.UserId = l.CreatedBy
         WHERE l.AprovedBy IS NOT NULL
               AND l.AprovedBy > 0
               AND l.AgencyId = @AgencyId
               AND (CAST(l.AprovedDate AS DATE) >= CAST(@FromDate AS DATE)
                    OR @FromDate IS NULL)
               AND (CAST(l.AprovedDate AS DATE) <= CAST(@ToDate AS DATE)
                    OR @ToDate IS NULL)
					ORDER BY AprovedDate ASC
     END;
       
GO