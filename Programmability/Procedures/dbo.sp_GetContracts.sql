SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2024-07-24 CB/5972: Added refund fields info
-- 2024-07-30 DJ/5979: Added DepositRefundFee field
-- 2024-0807 DJ/5991: Added payment type to deposit refund operation
-- 2025-06-19 DJ/6592: MODULO PROPIEDADES - URL DETAILS PROPERTIES - SENT 05-27-2025

CREATE PROCEDURE [dbo].[sp_GetContracts] (@ContractId INT = NULL,
@ApartmentsId INT = NULL,
@Name VARCHAR(80) = NULL,
@Telephone VARCHAR(12) = NULL,
@Date DATETIME,
@ContractStatusId INT = NULL,
@UserId INT)
AS
BEGIN
  DECLARE @CurrentDate DATETIME;
  SET @CurrentDate = @Date;
  SELECT DISTINCT
    dbo.Contract.ContractId
   ,dbo.Contract.StartDate
   ,dbo.Contract.EndDate
   ,dbo.Contract.RentValue
   ,dbo.Contract.DownPayment
   ,
    --dbo.Contract.TenantId,
    --dbo.Tenants.Name,
    --dbo.Tenants.Telephone,
    --dbo.Tenants.TypeId,
    --dbo.Tenants.DocNumber,
    dbo.Contract.LengthId
   ,dbo.Apartments.Number
   ,dbo.Apartments.ApartmentsId
   ,dbo.Apartments.Bathrooms
   ,dbo.Apartments.Bedrooms
   ,dbo.Apartments.Size
   ,dbo.Contract.ClosedBy
   ,dbo.Contract.ClosedDate
   ,uc.Name ClosedByName
   ,
    --dbo.TypeID.Description AS TypeIDDescription, 
    dbo.Properties.PropertiesId
   ,dbo.Properties.Name AS PropertyName
   ,dbo.Properties.Address AS PropertyAddress
   ,dbo.Properties.PersonInChargeTelephone AS PersonInChargeTelephone
   ,dbo.Properties.PersonInCharge
   ,dbo.Properties.AddressCorporation
   ,
    --               dbo.Properties.EmailCorporation, 
    ZipCodes.ZipCode
   ,ZipCodes.City
   ,ZipCodes.StateAbre AS State
   ,dbo.fn_GetContractStatus(dbo.Contract.ContractId, @Date) AS StatusDescription
   ,dbo.Users.Name AS UserName
   ,dbo.Contract.CreationDate
   ,dbo.Contract.FinancingDeposit
   ,ISNULL(dbo.Contract.Adults, 0) Adults
   ,ISNULL(dbo.Contract.Children, 0) Children
   ,dbo.Contract.Pets
   ,dbo.Contract.PetsReason
   ,ISNULL(dbo.fn_GetContractAvailableDeposit(dbo.Contract.ContractId), 0) AS AvailableDeposit
   ,dbo.Contract.AgencyId
   ,DATEDIFF(DAY, CAST(@Date AS DATE), dbo.Contract.EndDate) AS DaysLeft
   ,0 AS Due
   ,dbo.ContractStatus.Code AS StatusCode
   ,dbo.ContractStatus.Description AS StatusDescription
   ,dbo.ContractStatus.ContractStatusId
   ,dbo.Contract.ContractFileName
   ,(SELECT
        Name
      FROM [dbo].[FN_GetContractTenantInfo](dbo.Contract.ContractId))
    Tenant
   ,(SELECT
        Telephone
      FROM [dbo].[FN_GetContractTenantInfo](dbo.Contract.ContractId))
    Telephone
   ,dbo.fn_GetContractIsExpired(dbo.Contract.ContractId, @CurrentDate) AS Expired
   ,dbo.Contract.AddTerms
   ,dbo.Contract.FeeDue
   ,dbo.Contract.FeeNfs
   ,dbo.Contract.Dayslate
   ,dbo.Contract.DaysMaxiAband
   ,dbo.Contract.MonthlyPaymentDate
   ,CASE
      WHEN @ContractId IS NULL THEN 0
      ELSE (SELECT TOP 1
            Paid
          FROM [dbo].[FN_GetRentPaymentValue](@ContractId, @Date))
    END AS Paid
   ,dbo.fn_GetContractCanEdit(dbo.Contract.ContractId, @Date, @UserId) AS CanEditContract
   ,dbo.Contract.DepositBankAccountId
   ,dbo.Contract.MoveInFee
   ,dbo.Contract.TextConsent
   ,dbo.Properties.Zelle
   ,dbo.Properties.ZelleEmail
   ,ba.FullAccount
   ,dbo.Bank.Name AS BankNameProperty
   ,dbo.AccountOwners.Name AS AccountOwnerName
   ,ba.AccountNumber
   ,ba.BankAccountId
   ,dbo.Properties.EmailCorporation
   ,dbo.Contract.RefundBy
   ,u.Name AS RefundByName
   ,dbo.Contract.RefundDate
   ,dbo.Contract.RefundUsd
   ,dbo.Contract.AgencyRefundId
   ,a.Code + ' - ' + a.Name AS AgencyRefundName
   ,dbo.Contract.DepositRefundFee
   ,dbo.Contract.DepositRefundPaymentTypeId
   ,pt.Description AS DepositRefundPaymentTypeDescription
   ,pt.Code AS DepositRefundPaymentTypeCode
   ,dbo.Contract.DepositRefundBankAccountId
   ,'**** ' + bac.AccountNumber + ' (' + b.Name + ')' AS DepositRefundBankAccountName
   ,dbo.Contract.DepositRefundCheckNumber
   ,dbo.Contract.AchDate
  FROM dbo.Contract
  INNER JOIN dbo.Apartments
    ON dbo.Contract.ApartmentId = dbo.Apartments.ApartmentsId
  INNER JOIN dbo.Properties
    ON dbo.Apartments.PropertiesId = dbo.Properties.PropertiesId
  INNER JOIN dbo.Users
    ON dbo.Users.UserId = dbo.Contract.CreatedBy
  INNER JOIN dbo.ContractStatus
    ON dbo.ContractStatus.ContractStatusId = dbo.Contract.Status
  INNER JOIN dbo.TenantsXcontracts tc
    ON tc.ContractId = Contract.ContractId
  INNER JOIN dbo.Tenants T
    ON T.TenantId = tc.TenantId
  INNER JOIN ZipCodes
    ON ZipCodes.ZipCode = dbo.Properties.ZipCode
  LEFT JOIN Users uc
    ON uc.UserId = dbo.Contract.ClosedBy

  LEFT JOIN dbo.BankAccountsXProviderBanks
    ON dbo.Properties.BankAccountId = dbo.BankAccountsXProviderBanks.BankAccountId
  LEFT JOIN dbo.AccountOwners
    ON dbo.BankAccountsXProviderBanks.AccountOwnerId = dbo.AccountOwners.AccountOwnerId
  LEFT OUTER JOIN dbo.BankAccounts ba
    ON dbo.Properties.BankAccountId = ba.BankAccountId
  LEFT JOIN dbo.Bank
    ON ba.BankId = dbo.Bank.BankId

  LEFT JOIN dbo.Users u
    ON u.UserId = dbo.Contract.RefundBy
  LEFT JOIN dbo.Agencies a
    ON a.AgencyId = dbo.Contract.AgencyRefundId
  LEFT JOIN dbo.PaymentTypesProperties pt
    ON pt.PaymentTypePropertiesId = dbo.Contract.DepositRefundPaymentTypeId
  LEFT JOIN dbo.BankAccounts bac
    ON bac.BankAccountId = dbo.Contract.DepositRefundBankAccountId
  LEFT JOIN dbo.Bank b
    ON b.BankId = bac.BankId
  WHERE dbo.Contract.ContractId = CASE
    WHEN @ContractId IS NULL THEN dbo.Contract.ContractId
    ELSE @ContractId
  END
  AND dbo.Contract.ApartmentId = CASE
    WHEN @ApartmentsId IS NULL THEN dbo.Contract.ApartmentId
    ELSE @ApartmentsId
  END
  AND T.Name = CASE
    WHEN @Name IS NULL THEN T.Name
    ELSE @Name
  END

 AND (
    @Telephone IS NULL OR @Telephone = '' 
    OR t.Telephone = @Telephone
)

  AND (dbo.ContractStatus.ContractStatusId = @ContractStatusId
  OR @ContractStatusId IS NULL);
--CASE
--  WHEN @Active = 1 THEN 'C01'
--  ELSE dbo.ContractStatus.Code
--END;
END;
GO