SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Creted by jt/1-07-2025 task 6622 Daily report mostrar solo cajeros con actividad correspondiente al filtro aplicado.
CREATE PROCEDURE [dbo].[sp_GetAllUsersDailysByAgencyByDates] @AgencyId     INT, 
                                                  @FromDate DATE = NULL, 
                                                  @ToDate DATE = NULL
AS
    BEGIN
SELECT DISTINCT
 Users.Name
 ,Users.UserId
 ,
  --  AgenciesxUser.AgencyId, 
  CASE
    WHEN Users.Name LIKE '% %' THEN LEFT(Users.Name, CHARINDEX(' ', Users.Name) - 1)
    ELSE Users.Name
  END AS NameUser
 ,IsManager AS IsManagerFromDB
 ,(SELECT TOP 1
      Name
    FROM CompanyInformation)
  AS NameCompany
 ,Users.Telephone
 ,Users.Telephone2
 ,Users.ZipCode
 ,Users.Address
 ,Users.[User]
 ,Users.Pass
 ,Users.UserType
 ,Users.Lenguage
 ,C.CashierId
 ,C.IsActive
 ,Users.[User]
 ,C.ViewReports
 ,C.AllowManipulateFiles
 ,C.AccessProperties
 ,C.IsManager
 ,C.IsComissions
 ,C.IsAdmin
FROM Daily D
INNER JOIN Cashiers C
  ON D.CashierId = C.CashierId
    AND D.AgencyId = @AgencyId
INNER JOIN Users
  ON C.UserId = Users.UserId
WHERE CAST(D.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
AND CAST(D.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
ORDER BY Users.Name ASC;
END;

--GO
--
--select * from Daily where  AgencyId = 4 ORder by DailyId desc 
GO