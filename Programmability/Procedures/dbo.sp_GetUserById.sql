SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetUserById](@UserId INT)
AS
     BEGIN
         SET NOCOUNT ON;
         DECLARE @log INT;
         SET @log =
         (
             SELECT COUNT(*)
             FROM Users(NOLOCK)
             WHERE [UserId] = @UserId
         );
         IF(@log > 0)
             BEGIN
                 DECLARE @userType INT;
                 SET @userType =
                 (
                     SELECT TOP 1 UserType
                     FROM Users
                     WHERE [UserId] = @UserId
                 );
                 IF(@userType = 1)
                     BEGIN
                         SELECT Users.UserId,
                                Users.Name,
                                CASE
                                    WHEN Users.Name LIKE '% %'
                                    THEN LEFT(Users.Name, CHARINDEX(' ', Users.Name)-1)
                                    ELSE Users.Name
                                END AS NameUser,
                                Users.Telephone,
                                Users.Telephone2,
                                Users.ZipCode,
                                Users.Address,
                                Users.[User],
                                Users.Pass,
                                Users.UserType,
                                Users.Lenguage,
                                Admin.AdminId,
                                'Admin' AS Rol,
                         (
                             SELECT TOP 1 Rights
                             FROM RightsxUser
                             WHERE RightsxUser.UserId = Users.UserId
                         ) AS RightsRaw,
                                Users.StartingDate,
                                Users.SocialSecurity,
                                Users.PaymentType,
                                Users.USD,
                                Users.BirthDay,
								 Users.[User],
								    (
                                SELECT TOP 1   SessionTimeout
                                FROM ConfigurationSession                         
                         ) AS SessionTimeout
                         FROM Users
                              INNER JOIN Admin ON Users.UserId = Admin.UserId
                         WHERE Users.[UserId] = @UserId;
                 END;
                     ELSE
                 IF(@userType = 2)
                     BEGIN
                         SELECT Users.UserId,
                                CASE
                                    WHEN Users.Name LIKE '% %'
                                    THEN LEFT(Users.Name, CHARINDEX(' ', Users.Name)-1)
                                    ELSE Users.Name
                                END AS NameUser,
                                Users.Name,
                                Users.Address,
                                Users.Telephone,
                                Users.Telephone2,
                                Users.ZipCode,
                                Users.Address,
                                Users.[User],
                                Users.Pass,
                                Users.UserType,
                                Users.Lenguage,
                                Cashiers.IsAdmin,
                                'Cashier' AS Rol,
                                Cashiers.CashierId,
                                Cashiers.IsActive,
                                Cashiers.ViewReports,
                                Cashiers.AllowManipulateFiles,
								Cashiers.AccessProperties,

                         (
                             SELECT TOP 1 Rights
                             FROM RightsxUser
                             WHERE RightsxUser.UserId = Users.UserId
                         ) AS RightsRaw,
                                Users.StartingDate,
                                Users.SocialSecurity,
                                Users.PaymentType,
                                Users.USD,
                                Users.BirthDay,
								 Users.[User],
								    (
                                SELECT TOP 1   SessionTimeout
                                FROM ConfigurationSession                         
                         ) AS SessionTimeout
                         FROM Users
                              INNER JOIN Cashiers ON Users.UserId = Cashiers.UserId
                         WHERE Users.[UserId] = @UserId;
                 END;
         END;
     END;

GO