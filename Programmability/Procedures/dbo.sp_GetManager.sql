SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetManager](@UserId INT)
AS
    BEGIN
        IF(NOT EXISTS
        (
            SELECT *
            FROM [Admin]
            WHERE UserId = @UserId
        ))
            BEGIN
                INSERT INTO [Admin]
                (UserId, 
                 IsManager
                )
                VALUES
                (@UserId, 
                 CAST(1 AS BIT)
                );
            END;
        SELECT Users.UserId,
               CASE
                   WHEN Users.Name LIKE '% %'
                   THEN LEFT(Users.Name, CHARINDEX(' ', Users.Name) - 1)
                   ELSE Users.Name
               END AS NameUser, 
               Users.Name, 
               Users.Telephone, 
               Users.Telephone2, 
               Users.ZipCode, 
               Users.Address, 
               Users.[User], 
               Users.Pass, 
               1 AS UserType, 
               Users.Lenguage, 
               Users.[User], 
               Admin.AdminId, 
               'Admin' AS Rol, 
        (
            SELECT TOP 1 Rights
            FROM RightsxUser
            WHERE RightsxUser.UserId = Users.UserId
        ) AS RightsRaw, 
               c.CashierId,
               --isnull(Users.StartingDate,'') as StartingDate,
               Users.StartingDate, 
               Users.SocialSecurity, 
               Users.PaymentType, 
               Users.USD, 
               Users.BirthDay, 
               CAST(1 AS BIT) AS IsManager,
			                            (
                                SELECT TOP 1   SessionTimeout
                                FROM ConfigurationSession                          
                         ) AS SessionTimeout
        FROM Users
             INNER JOIN Admin ON Users.UserId = Admin.UserId
             INNER JOIN Cashiers c ON c.UserId = Users.UserId
        WHERE Users.UserId = @UserId
              AND Admin.IsManager = 1;
    END;
GO