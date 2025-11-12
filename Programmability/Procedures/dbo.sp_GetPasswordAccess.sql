SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPasswordAccess]
(@UserId      INT,
 @CurrentDate DATETIME
)
AS
     BEGIN
         SELECT 
		 a.code + ' - ' + a.Name AS AgencyCode, 
		 a.Name AS Agency,
                u2.Name AS OwnerCashier,
                p.*,
                u1.Name AS CreatedByName
         FROM [dbo].[PassAccess] p
              INNER JOIN [dbo].[Users] u1 ON p.CreatedBy = u1.UserId
              INNER JOIN [dbo].[Agencies] a ON p.AgencyId = a.AgencyId
              INNER JOIN [dbo].[Cashiers] c ON p.OwnerUserId = c.UserId
              INNER JOIN [dbo].[Users] u2 ON c.UserId = u2.UserId
         WHERE p.UserId = @UserId
               AND (CAST(@CurrentDate AS DATE) BETWEEN CAST(p.[FromDate] AS DATE) AND CAST(p.[ToDate] AS DATE));
     END;
GO