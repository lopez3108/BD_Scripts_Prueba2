SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Last update by jt/21-10-2024 --@ListAgenciId validate when is null or ''(string empty)

--Last update by jt/17-09-2024 task 6056 --Add new fields  LastTakeSickHrsOnFormat --Last date that take hours for the cashier and -LastTakeSickHrsBy --Last person that take hours for the cashier
--Last update by jt/14-08-2024 task 6003 -Sin importar que hayan SICK HOURS (AVAILABLE) el sistema ya no debe de mostrar en la alerta los cajeros inactivos (la regulación dice que si un cajero renuncia o es despedido y tiene SICK HOURS (AVAILABLE) no es responsabilidad del empleador pagarlas)
--Last update by jt/12-08-2024 task 5878 Change logic of calculate sick hours

--Last update by jt/25-07-2024 task 5878 Change logic of calculate sick hours

-- =============================================
-- Author:      JF
-- Create date: 21/07/2024 4:44 p. m.
-- Database:    copiaDevtest
-- Description: task 5956 Registrar fecha y persona que editar el salario a algún cajero
-- =============================================
-- =============================================
-- Author:      JF
-- Create date: 31/07/2024 4:49 p. m.
-- Database:    devCopySecure
-- Description: task 5980  Validación sick hours accumulate
-- =============================================
--Updated by jt/15-06-2025  Add new module LEAVE HOURS


--EXEC [dbo].[sp_GetAllCashiers] null
CREATE     PROCEDURE [dbo].[sp_GetAllCashiers] @CashierId INT = NULL, 
@ListAgenciId VARCHAR(1000) = NULL,
--@AgencyId INT = NULL,
@Active BIT = NULL,
@Telephone VARCHAR(10) = NULL,
@Name VARCHAR(80) = NULL,
@IsManager BIT = NULL,
@IsAdmin BIT = NULL,
@UserId INT = NULL,
@IsSick BIT = NULL,
@IsVacation BIT = NULL,
@RolComplianceId INT = NULL,
@CurrentDate DATETIME = NULL
AS
BEGIN
SELECT DISTINCT
  Cashiers.CashierId
 ,Cashiers.UserId
 ,Users.UserId AS Expr1
 ,Users.Name
 ,Users.Telephone
 ,Users.Telephone2
 ,Users.Telephone AS TelephoneSaved
 ,Users.ZipCode
 ,Users.Address
 ,Users.[User] AS Email
 ,Users.[User] AS EmailSaved
 ,Users.Pass
 ,Users.UserType
 ,Users.Lenguage
 ,UPPER(ZipCodes.City) AS City
 ,UPPER(ZipCodes.State) +
  CASE
    WHEN ZipCodes.StateAbre IS NULL THEN ''
    ELSE ' - ' + ZipCodes.StateAbre
  END AS State
 ,UPPER(ZipCodes.County) AS County
 ,Cashiers.IsActive
 ,CASE
    WHEN Cashiers.IsActive = 1 THEN 'ACTIVE'
    ELSE 'INACTIVE'
  END AS [IsActiveFormat]
 ,ViewReports
 ,AllowManipulateFiles
 ,Users.StartingDate
 ,CAST([dbo].[CalculateVacations](Cashiers.UserId, Cashiers.CycleDateVacation, NULL) AS DECIMAL(18, 2)) AS VacationHours
 ,dbo.fn_CalculateFractionToTimeString(CAST([dbo].[CalculateVacations](Cashiers.UserId, Cashiers.CycleDateVacation, NULL) AS DECIMAL(18, 2))) AS VacationHoursTime

 ,CAST([dbo].fnu_CalculateLeaveHours(Cashiers.UserId, Cashiers.CycleDateLeaveHours, NULL) AS DECIMAL(18, 2)) AS LeaveHours
 ,dbo.fn_CalculateFractionToTimeString(CAST([dbo].fnu_CalculateLeaveHours(Cashiers.UserId, Cashiers.CycleDateLeaveHours, NULL) AS DECIMAL(18, 2))) AS LeaveHoursTime
 ,--Cashiers.CashFund, 
  Users.SocialSecurity
 ,Users.SocialSecurity AS SocialSecuritySaved
 ,Users.PaymentType
 ,Users.PaymentType AS PaymentTypeSaved
 ,Users.USD
 ,Users.USD AS USDSaved
 ,Users.HoursPromedial
 ,Users.BirthDay
 ,ISNULL(Users.TelIsCheck, CAST(0 AS BIT)) TelIsCheck
 ,ISNULL(Users.EmailIsCheck, CAST(0 AS BIT)) EmailIsCheck
 ,CAST((ISNULL((SELECT
      SUM(cmc.CreditCashFund)
    FROM CashFundModifications cmc
    WHERE cmc.CashierId = dbo.Cashiers.CashierId)
  , 0) -
  ISNULL((SELECT
      SUM(cmc.DebitCashFund)
    FROM CashFundModifications cmc
    WHERE cmc.CashierId = dbo.Cashiers.CashierId)
  , 0)
  ) AS DECIMAL(18, 2)) AS CashFund
 ,IsManager
 ,IsAdmin
 ,SecurityLevelId
 ,ComplianceRol
 ,RC.RolName
 ,CAST(Cashiers.ValidComissions AS DATE) ValidComissions
 ,Cashiers.IsComissions
 ,CAST(0 AS BIT) isOnline
 ,CAST(0 AS BIT) hasNewPrivateMessage
 ,ISNULL((SELECT
      SUM(CASE
        WHEN r.ReadUserId = @UserId THEN 0
        ELSE 1
      END) AS WhioutRead
    FROM ChatMessages c
    LEFT JOIN ReadsByChat r
      ON c.ChatMessageId = r.ChatMessageId
      AND r.ReadUserId = @UserId
    WHERE c.ToGroupId IS NULL
    AND c.ToUserId = @UserId
    AND c.FromUserId = Users.UserId)
  , 0) numNewMsg
 ,dbo.Cashiers.CycleDateVacation
  ,dbo.Cashiers.CycleDateLeaveHours

 ,CAST(Users.VacationHoursAccumulated AS DECIMAL(18, 2)) AS VacationHoursAccumulated
 ,CAST(Users.VacationHoursAccumulated AS DECIMAL(18, 2)) AS VacationHoursAccumulatedSaved
 ,IsSocialSecurityInternal
 ,IsW4Internal
 ,IsConfidentialityInternal
 ,IsAddressProofInternal
 ,IsDirectDepositInternal
 ,IsBiometricInformationInternal
 ,IsIdentificationInternal
 ,IsEmploymentApplicationInternal
 ,Users.UserCreatedOn
 ,Users.UserCreatedBy
 ,Users.UserLastUpdatedOn
 ,Users.UserLastUpdatedBy
 ,Users.[LastUpdatedStartingDate]
 ,Users.LastUpdatedStartingDateBy
 ,Users.LastUpdatedsalaryOn
 ,Users.LastUpdatedSickHrsOn
 ,Users.LastUpdatedSalaryBy
 ,Users.LastUpdatedSickHrsBy
 ,uc.Name AS UserCreatedByName
 ,ul.Name AS LastUpdatedByName
 ,uls.Name AS LastUpdatedStartingDateByName
 ,u.Name AS LastUpdatedSalaryByName
 ,u1.Name AS LastUpdatedSickHrsByName
 ,FORMAT(Users.[LastUpdatedStartingDate], 'MM-dd-yyyy h:mm:ss tt', 'en-US') LastUpdatedStartingDateFormat
 ,FORMAT(Users.UserLastUpdatedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US') LastUpdatedOnFormat
 ,FORMAT(Users.UserCreatedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreatedOnFormat
 ,FORMAT(Users.LastUpdatedsalaryOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US') LastUpdatedSalaryOnFormat
 ,FORMAT(Users.LastUpdatedSickHrsOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US') LastUpdatedSickHrsOnFormat
 ,(SELECT TOP 1
      FORMAT(Ev.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')
    FROM EmployeeVacations Ev
    INNER JOIN Users Uv
      ON Ev.CreatedBy = Uv.UserId
    WHERE Ev.UserId = Cashiers.UserId
    ORDER BY EmployeeVacationsId DESC)
  LastTakeSickHrsOnFormat --Last date that take hours for the cashier
 ,(SELECT TOP 1
      Uv.Name
    FROM EmployeeVacations Ev
    INNER JOIN Users Uv
      ON Ev.CreatedBy = Uv.UserId
    WHERE Ev.UserId = Cashiers.UserId
    ORDER BY EmployeeVacationsId DESC)
  LastTakeSickHrsBy --Last person that take hours for the cashier
 ,(SELECT TOP 1
      CAST(1 AS BIT)
    FROM Payrolls ps
    WHERE ps.UserId = Users.UserId
    AND (MONTH(ps.PaidOn) = MONTH(Users.StartingDate)))
  AS SickHourMothPayed

 ,(SELECT TOP 1
      CAST(1 AS BIT)
    FROM EmployeeVacations ev
    WHERE ev.UserId = Users.UserId)
  AS SickHourTaken
 ,ISNULL(Users.VacationHoursAccumulated, 0) VacationHoursAccumulated





 ,(SELECT TOP 1
      FORMAT(Ev.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')
    FROM EmployeeLeaveHours Ev
    INNER JOIN Users Uv
      ON Ev.CreatedBy = Uv.UserId
    WHERE Ev.UserId = Cashiers.UserId
    ORDER BY EmployeeLeaveHoursId DESC)
  LastTakeLeaveHrsOnFormat --Last date that take leave hours for the cashier
 ,(SELECT TOP 1
      Uv.Name
    FROM EmployeeLeaveHours Ev
    INNER JOIN Users Uv
      ON Ev.CreatedBy = Uv.UserId
    WHERE Ev.UserId = Cashiers.UserId
    ORDER BY EmployeeLeaveHoursId DESC)
  LastTakeLeaveHrsBy --Last person that take leave hours for the cashier


FROM dbo.Cashiers
INNER JOIN Users
  ON Cashiers.UserId = Users.UserId
LEFT JOIN Users uc
  ON uc.UserId = Users.UserCreatedBy
LEFT JOIN Users ul
  ON ul.UserId = Users.UserLastUpdatedBy
LEFT JOIN Users uls
  ON uls.UserId = Users.LastUpdatedStartingDateBy
LEFT JOIN Users u
  ON u.UserId = Users.LastUpdatedSalaryBy
LEFT JOIN Users u1
  ON u1.UserId = Users.LastUpdatedSickHrsBy
LEFT JOIN ZipCodes
  ON Users.ZipCode = ZipCodes.ZipCode
LEFT JOIN AgenciesxUser
  ON AgenciesxUser.UserId = Cashiers.UserId
LEFT JOIN RolCompliance RC
  ON RC.RolComplianceId = Cashiers.ComplianceRol
WHERE (Cashiers.CashierId = @CashierId
OR @CashierId IS NULL)
AND (Cashiers.IsActive = @Active
OR @Active IS NULL)
AND ((@IsSick = 1
AND ((SELECT
    [dbo].[CalculateVacations](Cashiers.UserId, Cashiers.CycleDateVacation, NULL))
> 0))
OR @IsSick = 0)
AND ((@IsVacation = 1
AND ((SELECT
    [dbo].[fnu_CalculateLeaveHours](Cashiers.UserId, Cashiers.CycleDateLeaveHours, NULL))
> 0))
OR @IsVacation = 0)

AND (AgenciesxUser.AgencyId IN (SELECT
    item
  FROM dbo.FN_ListToTableInt(@ListAgenciId))
OR (@ListAgenciId IS NULL
OR @ListAgenciId = ''))

--  AND (AgenciesxUser.AgencyId = @AgencyId
--  OR @AgencyId IS NULL)
AND (Users.Telephone LIKE '%' + @Telephone + '%'
OR @Telephone IS NULL)
AND (Users.Name LIKE '%' + @Name + '%'
OR @Name IS NULL)
AND (Cashiers.IsManager = @IsManager
OR @IsManager IS NULL)
AND (Cashiers.IsAdmin = @IsAdmin
OR @IsAdmin IS NULL)
AND (Cashiers.ComplianceRol = @RolComplianceId
OR @RolComplianceId IS NULL)



ORDER BY Users.Name;
END;
GO