SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-07-24 CB/5972: Added refund fields info
-- 2024-07-30 DJ/5979: Added DepositRefundFee field
-- 2024-0807 DJ/5991: Added payment type to deposit refund operation
-- 2025-05-27 DJ/6225: Nombre incorrecto al crear un Rent payment
-- 2025-09-05 JF/6722: Contracts deben poder quedar en status PENDING cuando se crean
--2025-10-20 JF / 6786 Ajuste para contratos cerrados el mismo día de creación

CREATE PROCEDURE [dbo].[sp_GetContractList] @ContractId INT = NULL,
@PropertyId INT = NULL,
@ApartmentId INT = NULL,
@Status VARCHAR(5) = NULL,
@Name VARCHAR(50) = NULL,
@CurrentDate DATETIME,
@UserId INT
AS
BEGIN
  SELECT DISTINCT
    dbo.Contract.ContractId
   ,dbo.Contract.ApartmentId
   ,dbo.Apartments.Number
   ,dbo.Apartments.Number AS ApartmentNumber
   ,dbo.Properties.PropertiesId
   ,dbo.Properties.PropertiesId AS PropertyId
   ,dbo.Properties.Name AS PropertyName
   ,dbo.Properties.Address AS PropertyAddress
   ,dbo.Properties.PersonInChargeTelephone AS PropertyPersonInChargeTelephone
   ,dbo.ZipCodes.ZipCode
   ,dbo.ZipCodes.City
   ,dbo.ZipCodes.StateAbre AS State
   ,dbo.Contract.StartDate
   ,FORMAT(Contract.StartDate, 'MM-dd-yyyy', 'en-US') StartDateFormat
   ,dbo.Contract.EndDate
   ,FORMAT(Contract.EndDate, 'MM-dd-yyyy', 'en-US') EndDateFormat
   ,UPPER(FORMAT(dbo.Contract.EndDate, 'MM/dd/yyyy', 'es-CO')) AS ContractExpirationDate
   ,CAST(dbo.Contract.RentValue AS FLOAT) AS RentValue
   ,dbo.Contract.DownPayment AS Deposit
   ,dbo.Contract.LengthId
   ,CASE
      WHEN dbo.Contract.LengthId = 1 THEN '6 MONTHS'
      ELSE '1 YEAR'
    END AS LengthDescription
   ,dbo.Contract.Status
   ,dbo.ContractStatus.ContractStatusId
   ,dbo.ContractStatus.Description AS StatusDescription
   ,dbo.Contract.CreationDate
   ,FORMAT(Contract.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat
   ,dbo.Contract.CreatedBy
   ,ISNULL(dbo.Contract.Adults, 0) AS Adults
   ,ISNULL(dbo.Contract.Children, 0) AS Children
   ,dbo.Contract.Pets
   ,dbo.Contract.PetsReason
   ,dbo.fn_GetContractAvailableDeposit(dbo.Contract.ContractId) AS AvailableDeposit
   ,(SELECT
        Name
      FROM [dbo].[FN_GetContractTenantInfo](dbo.Contract.ContractId))
    Tenant
   ,(SELECT
        Telephone
      FROM [dbo].[FN_GetContractTenantInfo](dbo.Contract.ContractId))
    Telephone
   ,CASE
      WHEN CAST(dbo.Contract.StartDate AS DATE) > CAST(@CurrentDate AS DATE) THEN DATEDIFF(DAY, CAST(dbo.Contract.StartDate AS DATE), CAST(dbo.Contract.EndDate AS DATE))
      ELSE CASE
          WHEN DATEDIFF(DAY, CAST(@CurrentDate AS DATE), dbo.Contract.EndDate) > 0 THEN DATEDIFF(DAY, CAST(@CurrentDate AS DATE), dbo.Contract.EndDate)
          ELSE 0
        END
    END AS DaysLeft
   ,dbo.fn_GetContractIsExpired(dbo.Contract.ContractId, @CurrentDate) AS Expired
   ,dbo.Contract.AgencyId
   ,Contract.ContractFileName
   ,0 Due
   ,dbo.ContractStatus.Code AS StatusCode
   ,dbo.Users.Name AS CreatedByName
   ,dbo.Contract.ClosedDate
   ,FORMAT(Contract.ClosedDate, 'MM-dd-yyyy', 'en-US') ClosedDateFormat
   ,dbo.Contract.ClosedBy
   ,uclo.Name AS ClosedByName
   ,Contract.ContractFileName
   ,Contract.Dayslate AS Dayslate
   ,Contract.MonthlyPaymentDate AS MonthlyPaymentDate
   ,Contract.FeeDue AS FeeDue
   ,dbo.fn_GetContractCanEdit(dbo.Contract.ContractId, @CurrentDate, @UserId) AS CanEditContract
   ,dbo.Contract.DepositBankAccountId
   ,dbo.Contract.MoveInFee
   ,dbo.Contract.TextConsent
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
   ,'**** ' + ba.AccountNumber + ' (' + b.Name + ')' AS DepositRefundBankAccountName
   ,dbo.Contract.DepositRefundCheckNumber
  FROM dbo.Properties
  INNER JOIN dbo.Apartments
    ON dbo.Properties.PropertiesId = dbo.Apartments.PropertiesId
  INNER JOIN dbo.Contract
    ON dbo.Apartments.ApartmentsId = dbo.Contract.ApartmentId
  INNER JOIN dbo.ContractStatus
    ON dbo.ContractStatus.ContractStatusId = dbo.Contract.Status
  INNER JOIN dbo.ZipCodes
    ON dbo.ZipCodes.ZipCode = dbo.Properties.Zipcode
  INNER JOIN dbo.Users
    ON dbo.Users.UserId = dbo.Contract.CreatedBy
  LEFT OUTER JOIN dbo.Users AS uclo
    ON uclo.UserId = dbo.Contract.ClosedBy
  INNER JOIN dbo.TenantsXcontracts tc
    ON tc.ContractId = Contract.ContractId
  INNER JOIN dbo.Tenants T
    ON T.TenantId = tc.TenantId
  LEFT JOIN dbo.Users u
    ON u.UserId = dbo.Contract.RefundBy
  LEFT JOIN dbo.Agencies a
    ON a.AgencyId = dbo.Contract.AgencyRefundId
  LEFT JOIN dbo.PaymentTypesProperties pt
    ON pt.PaymentTypePropertiesId = dbo.Contract.DepositRefundPaymentTypeId
  LEFT JOIN dbo.BankAccounts ba
    ON ba.BankAccountId = dbo.Contract.DepositRefundBankAccountId
  LEFT JOIN dbo.Bank b
    ON b.BankId = ba.BankId
  WHERE dbo.Contract.ContractId = CASE
    WHEN @ContractId IS NULL THEN dbo.Contract.ContractId
    ELSE @ContractId
  END
  AND dbo.Properties.PropertiesId = CASE
    WHEN @PropertyId IS NULL THEN dbo.Properties.PropertiesId
    ELSE @PropertyId
  END
  AND dbo.Contract.ApartmentId = CASE
    WHEN @ApartmentId IS NULL THEN dbo.Contract.ApartmentId
    ELSE @ApartmentId
  END
  AND T.Name LIKE CASE
    WHEN @Name IS NULL THEN T.Name
    ELSE '%' + @Name + '%'
  END
  AND (@Status IS NULL
  OR (@Status = 'C01'
  AND dbo.Contract.Status = (SELECT TOP 1
      ContractStatusId
    FROM ContractStatus
    WHERE Code = 'C01')
  AND [dbo].[fn_GetContractIsExpired](dbo.Contract.ContractId, @CurrentDate) = CAST(0 AS BIT))


  OR @Status IS NULL
  OR (@Status = 'C02'
  AND dbo.Contract.Status = (SELECT TOP 1
      ContractStatusId
    FROM ContractStatus
    WHERE Code = 'C02')
  )

  OR @Status IS NULL
  OR (@Status = 'C03'
  AND Contract.IsPendingInformation = 1
  )


  OR @Status IS NULL
  OR (@Status = 'C00'
  AND [dbo].[fn_GetContractIsExpired](dbo.Contract.ContractId, @CurrentDate) = CAST(1 AS BIT)
  AND dbo.Contract.Status = (SELECT TOP 1
      ContractStatusId
    FROM ContractStatus
    WHERE Code = 'C01')
  )
  
  
  )
  ORDER BY StatusDescription,
  PropertyName,
  Number;
END;


GO