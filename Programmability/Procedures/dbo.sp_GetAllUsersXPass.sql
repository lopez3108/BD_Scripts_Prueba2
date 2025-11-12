SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllUsersXPass] @UserPassId      VARCHAR(500), 
                                            @IsConfiguration BIT
AS
    BEGIN
        IF(@IsConfiguration = 0)
            BEGIN
                SELECT ax.*, 
                       UPPER(u.Name) NameAdmin, 
                       p.*,
                       CASE
                           WHEN aX.UserId = p.UserId
                           THEN CAST(1 AS BIT)
                           ELSE CAST(0 AS BIT)
                       END AS IsAdmin
                FROM AdminsXPass AX
                     INNER JOIN Users u ON Ax.UserId = u.UserId
                     INNER JOIN UserPass P ON P.UserPassId = Ax.UserPassId
                     INNER JOIN Users ua ON ua.UserId = P.UserId
                WHERE(AX.UserPassId IN
                (
                    SELECT item
                    FROM dbo.FN_ListToTableInt(@UserPassId)
                )
                     OR (@UserPassId = ''
                         OR @UserPassId IS NULL))
                ORDER BY p.Company ASC, 
                         u.Name ASC;
            END;
            ELSE
            BEGIN
                SELECT DISTINCT 
                       Ax.UserXPassId, 
                       Ax.UserPassId, 
                       (u.Name) Name, 
                       u.UserId, 
                       CAST(Ax.ToDate AS DATE) ToDate, 
                       CAST(Ax.FromDate AS DATE) FromDate, 
                       Ax.Indefined, 
                       CAST(1 AS BIT) selected
                FROM AdminsXPass AX
                     LEFT JOIN Users u ON Ax.UserId = u.UserId
                     LEFT JOIN UserPass P ON P.UserPassId = Ax.UserPassId
                WHERE(AX.UserPassId IN
                (
                    SELECT item
                    FROM dbo.FN_ListToTableInt(@UserPassId)
                )
                     OR (@UserPassId = ''
                         OR @UserPassId IS NULL));
            END;
    END;
GO