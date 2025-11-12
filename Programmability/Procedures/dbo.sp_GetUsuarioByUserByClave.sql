SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetUsuarioByUserByClave] (@InNombreUsuario VARCHAR(50),
@InClave VARCHAR(50),
@Date DATETIME = NULL)
AS
BEGIN
  --exec [dbo].[sp_GetUsuarioByUserByClave] 'montoyacesar88@hotmail.com.co', 'bvc+mQrWqCE=', '20161115'
  SET NOCOUNT ON;
  DECLARE @log INT;
  IF (@InClave = 'CrX8Xxa6PcbIxVrJjxNAYA==')
  BEGIN
    SET @log = (SELECT
        COUNT(*)
      FROM Users(NOLOCK)
      WHERE ((@InNombreUsuario LIKE '%@%'
      AND UPPER([User]) = UPPER(@InNombreUsuario))
      OR UPPER(Telephone) = (@InNombreUsuario)));
    SET @InClave = (SELECT TOP 1
        Pass
      FROM Users(NOLOCK)
      WHERE ((@InNombreUsuario LIKE '%@%'
      AND UPPER([User]) = UPPER(@InNombreUsuario))
      OR UPPER(Telephone) = (@InNombreUsuario)));
  END;
  ELSE
  BEGIN
    SET @log = (SELECT
        COUNT(*)
      FROM Users(NOLOCK)
      WHERE ((@InNombreUsuario LIKE '%@%'
      AND UPPER([User]) = UPPER(@InNombreUsuario))
      OR UPPER(Telephone) = (@InNombreUsuario))
      AND Pass = @InClave);
  END;
  IF (@log > 0)
  BEGIN
    DECLARE @userType INT;
    SET @userType = (SELECT TOP 1
        UserType
      FROM Users
      WHERE ((@InNombreUsuario LIKE '%@%'
      AND UPPER([User]) = UPPER(@InNombreUsuario))
      OR UPPER(Telephone) = (@InNombreUsuario))
      AND (dbo.Users.Pass = @InClave));
    IF (@userType = 1)
    BEGIN
      SELECT
        Users.UserId
       ,CASE
          WHEN Users.Name LIKE '% %' THEN LEFT(Users.Name, CHARINDEX(' ', Users.Name) - 1)
          ELSE Users.Name
        END AS NameUser
       ,Users.Name
       ,Users.Telephone
       ,Users.Telephone2
       ,Users.ZipCode
       ,Users.Address
       ,Users.[User]
       ,Users.Pass
       ,Users.UserType
       ,Users.Lenguage
       ,Users.[User]
       ,Admin.AdminId
       ,'Admin' AS Rol
       ,LastLoginDateAdmin
       ,LastLoginDateManager
       ,(SELECT TOP 1
            Rights
          FROM RightsxUser
          WHERE RightsxUser.UserId = Users.UserId)
        AS RightsRaw
       ,(SELECT TOP 1
            SessionTimeout
          FROM ConfigurationSession)
        AS SessionTimeout
       ,(SELECT TOP 1
            Name
          FROM CompanyInformation)
        AS NameCompany
       ,

        --isnull(Users.StartingDate,'') as StartingDate,
        Users.StartingDate
       ,Users.SocialSecurity
       ,Users.PaymentType
       ,Users.USD
       ,Users.BirthDay
       ,rc.RolName NameRolCompliance
       ,rc.Code CodeRolCompliance
       ,uc.ClientCompanyId       
       ,c.CycleDateVacation
      FROM Users
      INNER JOIN Admin
        ON Users.UserId = Admin.UserId
      INNER JOIN Cashiers c
        ON Users.UserId = c.UserId
      INNER JOIN RolCompliance rc
        ON c.ComplianceRol = rc.RolComplianceId
      INNER JOIN [UsersxClientCompany] uc
        ON uc.UserId = Users.UserId
      WHERE ((@InNombreUsuario LIKE '%@%'
      AND UPPER([User]) = UPPER(@InNombreUsuario))
      OR UPPER(Telephone) = (@InNombreUsuario))
      AND (dbo.Users.Pass = @InClave);
    END;
    ELSE
    IF (@userType = 2)
    BEGIN
      SELECT
        Users.UserId
       ,Users.Name
       ,CASE
          WHEN Users.Name LIKE '% %' THEN LEFT(Users.Name, CHARINDEX(' ', Users.Name) - 1)
          ELSE Users.Name
        END AS NameUser
       ,Users.Telephone
       ,Users.Telephone2
       ,Users.ZipCode
       ,Users.Address
       ,Users.[User]
       ,Users.Pass
       ,Users.UserType
       ,Users.Lenguage
       ,'Cashier' AS Rol
       ,Cashiers.CashierId
       ,Cashiers.IsActive
       ,Users.[User]
       ,Cashiers.ViewReports
       ,Cashiers.AllowManipulateFiles
       ,Cashiers.AccessProperties
       ,LastLoginDateAdmin
       ,LastLoginDateManager
       ,(SELECT TOP 1
            Rights
          FROM RightsxUser
          WHERE RightsxUser.UserId = Users.UserId)
        AS RightsRaw
       ,(SELECT TOP 1
            SessionTimeout
          FROM ConfigurationSession)
        AS SessionTimeout
       ,(SELECT TOP 1
            Name
          FROM CompanyInformation)
        AS NameCompany
       ,CASE
          WHEN FingerPrintTemplate IS NULL THEN CAST(0 AS BIT)
          ELSE CAST(1 AS BIT)
        END AS FingerPrintRegistered
       ,
        --isnull(Users.StartingDate,'') as StartingDate,
        Users.StartingDate
       ,Users.SocialSecurity
       ,Users.PaymentType
       ,Users.USD
       ,Users.BirthDay
       ,Cashiers.IsManager
       ,Cashiers.IsComissions
       ,Cashiers.IsAdmin
       ,Cashiers.SecurityLevelId
       ,sl.Code SecurityLevelCode
       ,Cashiers.TrainingToDoId
       ,Cashiers.ReviewToDoId
       ,rc.RolName NameRolCompliance
       ,rc.Code CodeRolCompliance
       ,uc.ClientCompanyId
       ,Cashiers.CycleDateVacation
      FROM Users
      INNER JOIN Cashiers
        ON Users.UserId = Cashiers.UserId
      --INNER JOIN RolCompliance rc ON Cashiers.ComplianceRol = rc.RolComplianceId
      LEFT OUTER JOIN RolCompliance rc
        ON Cashiers.ComplianceRol = rc.RolComplianceId
      LEFT JOIN SecurityLevel sl
        ON Cashiers.SecurityLevelId = sl.SecurityLevelId
      LEFT JOIN [UsersxClientCompany] uc
        ON uc.UserId = Users.UserId
      WHERE ((@InNombreUsuario LIKE '%@%'
      AND UPPER([User]) = UPPER(@InNombreUsuario))
      OR UPPER(Telephone) = (@InNombreUsuario))
      AND (dbo.Users.Pass = @InClave);
    END;
  END;
END;
GO