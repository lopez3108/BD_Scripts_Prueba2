SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetCashiersXAgncyXPendingProccessCheck] @AgencyId INT = NULL,
@IsActive BIT = NULL
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
   ,c.CashierId
   ,c.IsActive
   ,Users.[User]
   ,c.ViewReports
   ,c.AllowManipulateFiles
   ,c.AccessProperties
   ,c.IsManager
   ,c.IsComissions
   ,c.IsAdmin
  FROM Cashiers c
  INNER JOIN Users
    ON c.UserId = Users.UserId
  INNER JOIN AgenciesxUser
    ON AgenciesxUser.UserId = c.UserId
  WHERE (c.IsActive = @IsActive
  OR @IsActive IS NULL)
  AND (EXISTS (SELECT
      rp.CreatedBy
    FROM ReturnPayments rp
    JOIN ReturnPaymentMode rpm
      ON rp.ReturnPaymentModeId = rpm.ReturnPaymentModeId
    WHERE rp.CreatedBy = c.UserId
    AND rpm.Code = 'C01'
    AND rp.PaymentChecksAgentToAgentId IS NULL
    AND rp.AgencyId = @AgencyId
    OR @AgencyId IS NULL)
  )
  OR EXISTS (SELECT
      ce.CreatedBy
    FROM ChecksEls ce
    WHERE ce.CreatedBy = c.UserId
    AND ce.PaymentChecksAgentToAgentId IS NULL
    AND ce.AgencyId = @AgencyId)
  OR EXISTS (SELECT
      p.CreatedBy
    FROM [ProviderCommissionPayments] p
    WHERE p.CreatedBy = c.UserId
    AND p.CheckNumber IS NOT NULL
    AND p.PaymentChecksAgentToAgentId IS NULL
    AND p.AgencyId = @AgencyId)
  OR EXISTS (SELECT
      p.CreatedBy
    FROM [ProviderCommissionPayments] p
    INNER JOIN dbo.OtherCommissions oc
      ON p.ProviderCommissionPaymentId = oc.ProviderCommissionPaymentId
    WHERE p.CreatedBy = c.UserId
    AND oc.CheckNumber IS NOT NULL
    AND oc.PaymentChecksAgentToAgentId IS NULL
    AND p.AgencyId = @AgencyId)

END;

GO