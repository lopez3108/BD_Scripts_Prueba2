SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetCashiersXAgencyId] @AgencyId INT = NULL, 
                                                @IsActive BIT = NULL
AS
    BEGIN
        SELECT DISTINCT
               Users.Name, 
               Users.UserId, 
             --  AgenciesxUser.AgencyId, 
			     CASE
                     WHEN Users.Name LIKE '% %'
                     THEN LEFT(Users.Name, CHARINDEX(' ', Users.Name) - 1)
                     ELSE Users.Name
                 END AS NameUser, 
			   IsManager as IsManagerFromDB,
			   (
                  SELECT TOP 1   Name
                  FROM CompanyInformation                         
                ) AS NameCompany,
				Users.Telephone, 
                Users.Telephone2, 
                Users.ZipCode, 
                Users.Address, 
                Users.[User], 
                Users.Pass, 
                Users.UserType, 
                Users.Lenguage, 
                Cashiers.CashierId, 
                Cashiers.IsActive, 
                Users.[User], 
                Cashiers.ViewReports, 
                Cashiers.AllowManipulateFiles, 
                Cashiers.AccessProperties,
				Cashiers.IsManager, 
                Cashiers.IsComissions, 
                Cashiers.IsAdmin
     FROM Cashiers
             INNER JOIN Users ON Cashiers.UserId = Users.UserId
             INNER JOIN AgenciesxUser ON AgenciesxUser.UserId = Cashiers.UserId
        WHERE(AgenciesxUser.AgencyId = @AgencyId
              OR @AgencyId IS NULL)
             AND (Cashiers.IsActive = @IsActive
                  OR @IsActive IS NULL)
        ORDER By Users.Name ASC;
    END;

GO