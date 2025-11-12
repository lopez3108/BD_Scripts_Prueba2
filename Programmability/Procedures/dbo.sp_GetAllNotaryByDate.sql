SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllNotaryByDate]
(@From      DATE,
 @To        DATE,
 @AgencyId  INT,
 @CreatedBy INT
)
AS
     BEGIN
         SELECT SUM(dbo.Notary.Usd) AS USD,
                CAST(dbo.Notary.CreationDate AS DATE) AS Date,
                'NOTARY' AS Name
         FROM dbo.Notary
         WHERE CAST(dbo.Notary.CreationDate AS DATE) >= CAST(@From AS DATE)
               AND CAST(dbo.Notary.CreationDate AS DATE) <= CAST(@To AS DATE)
               AND CreatedBy = @CreatedBy
               AND AgencyId = @AgencyId
         GROUP BY CAST(dbo.Notary.CreationDate AS DATE);
     END;
GO