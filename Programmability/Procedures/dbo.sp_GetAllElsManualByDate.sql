SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllElsManualByDate]
(@From      DATE,
 @To        DATE,
 @AgencyId  INT,
 @CreatedBy INT
)
AS
     BEGIN
         SELECT CAST(dbo.Titles.CreationDate AS DATE) AS Date,
                SUM(USD) AS USD,
                'ELS MANUAL' AS Name
         FROM dbo.Titles
         WHERE CAST(dbo.Titles.CreationDate AS DATE) >= CAST(@From AS DATE)
               AND CAST(dbo.Titles.CreationDate AS DATE) <= CAST(@To AS DATE)
               AND CreatedBy = @CreatedBy
               AND AgencyId = @AgencyId
               AND ProcessAuto = 0
         GROUP BY CAST(dbo.Titles.CreationDate AS DATE);
     END;
GO