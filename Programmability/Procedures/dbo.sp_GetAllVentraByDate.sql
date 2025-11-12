SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllVentraByDate]
(@From      DATE,
 @To        DATE,
 @AgencyId  INT,
 @CreatedBy INT
)
AS
     BEGIN
         
		 SELECT sum(t.Usd)  as Usd, t.Date , t.Name FROM
		 (SELECT 
		 --Comentado en la Task 4821 punto 2. 
         --SUM(ISNULL(ReloadUsd,0)) AS USD,
		 --Task 4821 punto 2. 
		 --SE calcula el valor del ventra que sería valor ReloadUsd + comisión  (ReloadUsd - ((ReloadUsd * Commission)) / 100) + ((ReloadUsd * Commission) / 100)
           --((ISNULL(dbo.Ventra.ReloadUsd, 0)) - (((ISNULL(dbo.Ventra.ReloadUsd, 0)) * ISNULL((dbo.Ventra.Commission), 0)) / 100)) + (ISNULL((dbo.Ventra.ReloadUsd), 0) * ISNULL(dbo.Ventra.Commission, 0) / 100) AS Usd,
                    (ISNULL(dbo.Ventra.ReloadUsd, 0))  AS Usd,
				CAST(dbo.Ventra.CreationDate AS DATE) AS Date,
                'VENTRA' AS Name
         FROM dbo.Ventra
         WHERE CAST(dbo.Ventra.CreationDate AS DATE) >= CAST(@From AS DATE)
               AND CAST(dbo.Ventra.CreationDate AS DATE) <= CAST(@To AS DATE)
               AND CreatedBy = @CreatedBy
               AND AgencyId = @AgencyId
			   )t
         GROUP BY CAST(t.Date AS DATE), t.Name
     END;
GO