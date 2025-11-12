SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		Juan Felipe
-- Create date: 24Abril2023
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[sp_GetFilesProviderStatements]
@AgencyId INT = NULL,
@ProviderId INT = NULL,
@StartDate DATETIME  = NULL,
@EndDate DATETIME  = NULL,
@SearchByRangePeriod BIT ,
@ListMonthsSelected VARCHAR(1000) = NULL,
@ListYearsSelected VARCHAR(1000) = NULL

AS
     BEGIN

	SELECT 
         p.ProviderStatementsId,
         p.Year,
         p.Month,
         m.Description AS MonthDescription , 
         p.ProviderId,
         p1.Name AS ProviderName,
         a.Code + ' - ' + a.Name Agency,
         p.AgencyId,
         p.Name,      
         p.Extension,
         u.Name AS CreatedByName,         
         FORMAT(p.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat 
  
  FROM ProviderStatements p
  INNER JOIN Agencies a ON p.AgencyId = a.AgencyId
  INNER JOIN Providers p1 ON p1.ProviderId = p.ProviderId
  INNER JOIN Months m ON m.MonthId = p.Month
  INNER JOIN Users u ON u.UserId = p.UserId
  WHERE      ( p.AgencyId = @AgencyId OR @AgencyId IS NULL)
                AND ( p.ProviderId = @ProviderId OR @ProviderId IS NULL)
                AND ((CAST(p.CreationDate AS DATE) >= CAST(@StartDate AS DATE) OR @StartDate IS NULL )
                AND (CAST(p.CreationDate AS DATE) <= CAST(@EndDate AS DATE) OR @EndDate IS NULL))
                AND (p.Month IN (SELECT
                     item
               FROM dbo.FN_ListToTableInt(@ListMonthsSelected))
                  OR @ListMonthsSelected IS NULL)  
                  AND (p.Year IN (SELECT
                     item
               FROM dbo.FN_ListToTableInt(@ListYearsSelected))
      OR @ListYearsSelected IS NULL)
	 END
GO