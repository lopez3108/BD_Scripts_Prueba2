SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--CREATED BY : JT
--LASTUPDATEDON:23-04-2024
--List all cashiers that having pending missing in the gency, or these cashier are actives in the agency

--UPDATET BY : JT/03-03-2024 TASK 5834 List missings solo mostrar empleados pendientes de missing 

-- 2025-07-15 JT/6603: Missing payments managers

CREATE PROCEDURE [dbo].[sp_GetAllCashiersMissingXAgencyId] @AgencyId INT = NULL
--,@IsActive BIT = NULL
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
   ,Cashiers.CashierId
   ,Cashiers.IsActive
   ,Users.[User]
   ,Cashiers.ViewReports
   ,Cashiers.AllowManipulateFiles
   ,Cashiers.AccessProperties
   ,Cashiers.IsManager
   ,Cashiers.IsComissions
   ,Cashiers.IsAdmin
  FROM Cashiers
  INNER JOIN Users
    ON Cashiers.UserId = Users.UserId
  --  INNER JOIN AgenciesxUser
  --    ON AgenciesxUser.UserId = Cashiers.UserId
  WHERE
  --  ((AgenciesxUser.AgencyId = @AgencyId
  --  OR @AgencyId IS NULL)
  --  AND (Cashiers.IsActive = 1
  ----  OR 1 IS NULL
  --  )  )
  --  OR 
  (
  --Se verifica solo los pagos que estan pendientes donde el (missing - pago) <> 0 
  (SELECT
      [dbo].FN_GenerateBalanceMissing(@AgencyId, Cashiers.CashierId, NULL, NULL, NULL))
  <> 0)
  ORDER BY Users.Name ASC;
END;




GO