SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllAminds] (@IsActive BIT = NULL)
AS
     BEGIN
         SELECT DISTINCT
                Users.Name,
                Users.UserId
         FROM Users
              INNER JOIN Cashiers  ON Cashiers.UserId = Users.UserId
         WHERE IsAdmin = 1 and (Cashiers.IsActive = @IsActive
                  OR @IsActive IS NULL)
				  ORDER BY Name ASC

     END;
GO