SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetFilesMsb] @CurrentDate DATETIME
AS
    BEGIN
        SELECT *, 
               u.Name AS CreatedByName, 
               f.CreationDate AS CreationDateSaved, 
               u.Name AS CreatedByName, 
               CAST(1 AS BIT) AS IsSaved, 
               CAST(0 AS BIT) AS IsModify,
               CASE
                   WHEN(ISNULL(DATEDIFF(day, @CurrentDate, f.ExpirationDate), 0)) < 0
                   THEN 0
                   ELSE(ISNULL(DATEDIFF(day, @CurrentDate, f.ExpirationDate), 0))
               END AS DaysLeft
        FROM dbo.Msb f
             INNER JOIN dbo.Users u ON f.CreatedBy = U.UserId
        ORDER BY ExpirationDate DESC;
    END;
GO