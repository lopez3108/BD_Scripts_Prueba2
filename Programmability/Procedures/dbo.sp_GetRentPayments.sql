SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-07-23 CB/5968: Include CARD PAYMENT payment type in the rent payments list
-- 8/09/2024  DJ/6049: Nueva columna grid rent payments
-- 2025-05-20 DJ/6521: Rent payments deben ser recibidos independientemente del status del Contract
-- 2025-09-15 JF/6722: Contracts deben poder quedar en status PENDING cuando se crean
-- 2025-10-09 JT/6774: Retornamos la última fecha que se pagó una renta 



CREATE PROCEDURE [dbo].[sp_GetRentPayments] (@Date DATETIME,
@Name VARCHAR(50) = NULL,
@Telephone VARCHAR(12) = NULL,
@PropertyId INT = NULL,
@ApartmentId INT = NULL,
@ContractId INT = NULL)
AS
BEGIN

  --SET @Date = '2022-09-15'

  DECLARE @month FLOAT;
  SET @month = DATEPART(MONTH, @Date);
  DECLARE @year FLOAT;
  SET @year = DATEPART(YEAR, @Date);
  SELECT
    InnerTable.ContractId
   ,InnerTable.ApartmentId
   ,InnerTable.StartDate
   ,InnerTable.EndDate
   ,InnerTable.ContractLenght
   ,InnerTable.RentValue
   ,InnerTable.Name
   ,InnerTable.Telephone
   ,InnerTable.TenantNamePrincpal
   ,InnerTable.Status
   ,InnerTable.CreationDate
   ,InnerTable.ToPay
   ,InnerTable.Paid
   ,InnerTable.Balance AS Balance
   ,CAST('' AS VARCHAR(15)) AS RentStatusCode
   ,CAST('' AS VARCHAR(15)) AS RentStatusDescription
   ,InnerTable.Number
   ,InnerTable.Property
   ,InnerTable.StatusDescription
   ,InnerTable.StatusDesc
   ,InnerTable.PaymentDate
   ,FORMAT(InnerTable.PaymentDate, 'MM-dd-yyyy', 'en-US') PaymentDateFormat
   ,InnerTable.PaidDate
   ,InnerTable.PaidBy
   ,InnerTable.Agency
   ,InnerTable.SMSMessage
   ,InnerTable.FinancingMessageId
   ,InnerTable.FinancingMessageTitle
   ,InnerTable.SMSMessageExpired
   ,InnerTable.FinancingMessageIdExpired
   ,InnerTable.FinancingMessageTitleExpired
   ,InnerTable.FinancingMessageCategoryIdExpired
   ,InnerTable.AdminId
   ,InnerTable.AgencyName
   ,InnerTable.AgencyPhone
   ,InnerTable.AgencyId
   ,InnerTable.PropertyAddress
   ,InnerTable.PropertiesId
   ,InnerTable.PropertyId
   ,InnerTable.CompanyPhone
   ,InnerTable.PropName
   ,InnerTable.Phone
   ,InnerTable.NameUser
   ,InnerTable.Cash
   ,InnerTable.AccountNumber
   ,
    --			   	InnerTable.PaymentType,
    InnerTable.DueDays
   ,CASE
      WHEN InnerTable.DueMonths <= 0 THEN 0
      ELSE InnerTable.DueMonths
    END AS DueMonths
   ,ISNULL(InnerTable.FeeDue, 0) AS FeeDue
   ,InnerTable.MonthlyPaymentDate
   ,InnerTable.Dayslate
   ,ISNULL(InnerTable.FeeDueConfig, 0) AS FeeDueConfig
   ,InnerTable.ContractStatusCode
   ,InnerTable.ContractStatusDescription
   ,CAST(0 AS DECIMAL(18, 2)) AS RentDue
   ,CAST(1 AS BIT) AS AllowOperations
   ,CAST(GETDATE() AS DATETIME) AS MaxPayDate
   ,InnerTable.MoveInFee
   ,InnerTable.NumberPayments
   ,InnerTable.PendingMoveInFee
   ,InnerTable.BankAccountId
   ,InnerTable.UsdPayment
   ,InnerTable.ClosedDate
   ,(SELECT TOP 1
        CASE
          WHEN rps.AchDate IS NOT NULL THEN rps.AchDate
          ELSE rps.CreationDate
        END
      FROM RentPayments rps
      WHERE rps.ContractId = InnerTable.ContractId
      ORDER BY rps.CreationDate DESC)
    AS LastPaidDate

  FROM (SELECT DISTINCT
      (SELECT TOP 1
          dbo.Users.UserId
        FROM dbo.Admin
        INNER JOIN dbo.Users
          ON dbo.Admin.UserId = dbo.Users.UserId)
      AS AdminId
     ,(SELECT TOP 1
          Message
        FROM FinancingMessages
        INNER JOIN [SMSCategories]
          ON SMSCategories.SMSCategoryId = FinancingMessages.SMSCategoryId
        WHERE [SMSCategories].Code = 'C04')
      AS SMSMessage
     ,(SELECT TOP 1
          FinancingMessageId
        FROM FinancingMessages
        INNER JOIN [SMSCategories]
          ON [SMSCategories].SMSCategoryId = FinancingMessages.SMSCategoryId
        WHERE [SMSCategories].Code = 'C04')
      AS FinancingMessageId
     ,(SELECT TOP 1
          Title
        FROM FinancingMessages
        INNER JOIN [SMSCategories]
          ON [SMSCategories].SMSCategoryId = FinancingMessages.SMSCategoryId
        WHERE [SMSCategories].Code = 'C04')
      AS FinancingMessageTitle
     ,(SELECT TOP 1
          Message
        FROM FinancingMessages
        INNER JOIN [SMSCategories]
          ON SMSCategories.SMSCategoryId = FinancingMessages.SMSCategoryId
        WHERE [SMSCategories].Code = 'C07')
      AS SMSMessageExpired
     ,(SELECT TOP 1
          FinancingMessageId
        FROM FinancingMessages
        INNER JOIN [SMSCategories]
          ON [SMSCategories].SMSCategoryId = FinancingMessages.SMSCategoryId
        WHERE [SMSCategories].Code = 'C07')
      AS FinancingMessageIdExpired
     ,(SELECT TOP 1
          Title
        FROM FinancingMessages
        INNER JOIN [SMSCategories]
          ON [SMSCategories].SMSCategoryId = FinancingMessages.SMSCategoryId
        WHERE [SMSCategories].Code = 'C07')
      AS FinancingMessageTitleExpired
     ,(SELECT TOP 1
          SMSCategories.SMSCategoryId
        FROM FinancingMessages
        INNER JOIN [SMSCategories]
          ON [SMSCategories].SMSCategoryId = FinancingMessages.SMSCategoryId
        WHERE [SMSCategories].Code = 'C07')
      AS FinancingMessageCategoryIdExpired
     ,Contract.ContractId
     ,ApartmentId
     ,StartDate
     ,EndDate
     ,RentValue
     ,CS.Description StatusDesc
     ,
      --Contract.TenantId, 
      --Tenants.Name, 
      --Tenants.Telephone, 
      Status
     ,CS.Code AS ContractStatusCode
     ,CS.Description AS ContractStatusDescription
     ,Contract.CreationDate
     ,Contract.MonthlyPaymentDate
     ,Contract.Dayslate
     ,Contract.FeeDue AS FeeDueConfig
     ,Contract.MoveInFee
     ,CASE
        WHEN (Contract.MoveInFee > 0 AND
          ISNULL((SELECT
              SUM(MoveInFee)
            FROM RentPayments rps
            WHERE rps.ContractId = Contract.ContractId)
          , 0) = 0) THEN Contract.MoveInFee
        ELSE 0
      END AS PendingMoveInFee
     ,(SELECT
          COUNT(*)
        FROM RentPayments rps
        WHERE rps.ContractId = Contract.ContractId)
      AS NumberPayments
     ,ISNULL((SELECT
          SUM(UsdPayment)
        FROM RentPayments rps
        WHERE rps.ContractId = Contract.ContractId)
      , 0) AS UsdPayment
     ,CAST(0 AS DECIMAL(18, 2)) AS ToPay
     ,CAST(0 AS DECIMAL(18, 2)) AS Paid
     ,CAST(0 AS DECIMAL(18, 2)) AS Balance
     ,Apartments.Number AS Number
     ,Properties.Name AS Property
     ,Properties.Address + ' ' + ZipCodes.City + ' ' + ZipCodes.StateAbre + ' ' + ZipCodes.ZipCode AS PropertyAddress
     ,CASE
        WHEN [dbo].[fn_GetRentDueDays](Contract.ContractId, @Date) <= 0 THEN 'UP TO DATE'
        ELSE 'EXPIRED'
      END AS StatusDescription
     ,CAST((CAST(@year AS VARCHAR(4)) + '-' + CAST(@month AS VARCHAR(2)) + '-' +
      CASE
        WHEN (@month = 2 AND
          (DATEPART(DAY, Contract.StartDate) = 31 OR
          DATEPART(DAY, Contract.StartDate) = 30 OR
          DATEPART(DAY, Contract.StartDate) = 29)) THEN '28'
        WHEN (DATEPART(DAY, Contract.StartDate) = 31) THEN CAST((SELECT
              DATEPART(DAY, DATEADD(MONTH, ((YEAR(CAST((CAST(CAST(@year AS VARCHAR(4)) + '-' + CAST(@month AS VARCHAR(2)) + '-01' AS DATETIME)) AS DATE)) - 1900) * 12) + MONTH(CAST((CAST(CAST(@year AS VARCHAR(4)) + '-' + CAST(@month AS VARCHAR(2)) + '-01' AS DATETIME)) AS DATE)), -1)))
          AS VARCHAR(2))
        ELSE CAST(DATEPART(DAY, Contract.StartDate) AS VARCHAR(2))
      END) AS DATETIME) AS PaymentDate
     ,(SELECT TOP 1
          r.CreationDate
        FROM RentPayments r
        WHERE r.ContractId = Contract.ContractId
        ORDER BY CreationDate DESC)
      AS PaidDate
     ,(SELECT TOP 1
          u.Name
        FROM RentPayments ru
        INNER JOIN Users u
          ON u.UserId = ru.CreatedBy
        WHERE ru.ContractId = Contract.ContractId
        ORDER BY ru.CreationDate DESC)
      AS PaidBy
     ,(SELECT TOP 1
          a.Code + ' - ' + a.Name
        FROM RentPayments ra
        INNER JOIN Agencies a
          ON Contract.AgencyId = a.AgencyId)
      AS Agency
     ,dbo.Agencies.Code + ' - ' + dbo.Agencies.Name AS AgencyName
     ,dbo.Agencies.Telephone AS AgencyPhone
     ,dbo.Agencies.AgencyId AS AgencyId
     ,Properties.PropertiesId
     ,Properties.PropertiesId AS PropertyId
     ,(SELECT TOP 1
          MonthsLate
        FROM [dbo].[FN_GetRentPaymentValue](Contract.ContractId, @Date))
      AS DueMonths
     ,(SELECT TOP 1
          FeeDue
        FROM [dbo].[FN_GetRentPaymentValue](Contract.ContractId, @Date))
      + ([dbo].[fn_GetRentPendingFeeDue](Contract.ContractId)) AS FeeDue
     ,(SELECT TOP 1
          ContractLenght
        FROM [dbo].[FN_GetRentPaymentValue](Contract.ContractId, @Date))
      AS ContractLenght
     ,(SELECT TOP 1
          DueDays
        FROM [dbo].[FN_GetRentPaymentValue](Contract.ContractId, @Date))
      AS DueDays
     ,
      --,CASE   comentado por  que debe cargar el que tiene el contrato 
      --   WHEN (EXISTS (SELECT TOP 1
      --         ISNULL(FeeDue, 0) AS FeeDue
      --       FROM PropertiesCOnfiguration)
      --     ) THEN (SELECT TOP 1
      --         ISNULL(FeeDue, 0) AS FeeDue
      --       FROM PropertiesCOnfiguration)
      --   ELSE 0
      -- END AS FeeDueConfig
      -------------------------------------------------------------------------------------------------------
      (SELECT
          Name
        FROM [dbo].[FN_GetContractTenantInfo](dbo.Contract.ContractId))
      Name
     ,(SELECT
          Telephone
        FROM [dbo].[FN_GetContractTenantInfo](dbo.Contract.ContractId))
      Telephone
     ,(SELECT
          Name
        FROM [dbo].[FN_GetContractTenantInfo](dbo.Contract.ContractId))
      TenantNamePrincpal
     ,Properties.PersonInChargeTelephone AS CompanyPhone
     ,Properties.Name AS PropName
     ,Properties.PersonInChargeTelephone AS Phone
     ,Users.Name AS NameUser
     ,(SELECT
          ISNULL(SUM(d.Cash), 0)
        FROM RentPayments d
        WHERE d.ContractId = dbo.Contract.ContractId)
      AS Cash
     ,(SELECT TOP 1
          ba1.AccountNumber
        FROM BankAccounts ba1
        LEFT JOIN RentPayments rp
          ON rp.BankAccountId = ba1.BankAccountId
        WHERE rp.ContractId = dbo.Contract.ContractId)
      AS AccountNumber
     ,CASE
        WHEN (SELECT
              ISNULL(SUM(rp.Cash), 0)
            FROM RentPayments rp
            WHERE rp.ContractId = dbo.Contract.ContractId)
          > 0 THEN 'CASH'
        WHEN (SELECT TOP 1
              rp.CardPayment
            FROM RentPayments rp
            WHERE rp.ContractId = dbo.Contract.ContractId)
          = 1 THEN 'CARD PAYMENT' --5968
        WHEN (EXISTS (SELECT TOP 1
              rp.BankAccountId
            FROM RentPayments rp
            WHERE rp.ContractId = dbo.Contract.ContractId)
          ) THEN 'ACCOUNT'

      END AS PaymentType
     ,Properties.BankAccountId
     ,dbo.Contract.ClosedDate
    FROM dbo.Contract

    INNER JOIN Apartments
      ON Apartments.ApartmentsId = Contract.ApartmentId
    INNER JOIN Properties
      ON Apartments.PropertiesId = Properties.PropertiesId
    INNER JOIN Agencies
      ON Agencies.AgencyId = dbo.Contract.AgencyId
    LEFT JOIN Users
      ON Users.UserId = dbo.Contract.CreatedBy
    INNER JOIN dbo.TenantsXcontracts tc
      ON tc.ContractId = Contract.ContractId
    INNER JOIN dbo.Tenants
      ON Tenants.TenantId = tc.TenantId
    --INNER JOIN Tenants ON Tenants.TenantId = Contract.TenantId
    INNER JOIN ZipCodes
      ON ZipCodes.ZipCode = Properties.ZipCode
    INNER JOIN dbo.ContractStatus CS
      ON CS.ContractStatusId = dbo.Contract.Status
    WHERE (@ContractId IS NULL
    OR dbo.Contract.ContractId = @ContractId)
    AND CAST(@Date AS DATE) >= CAST(dbo.Contract.StartDate AS DATE)
    AND Tenants.Name LIKE CASE
      WHEN @Name IS NULL THEN Tenants.Name
      ELSE '%' + @Name + '%'
    END
    AND (
    @Telephone IS NULL
    OR Tenants.Telephone LIKE '%' + @Telephone + '%'
    )

    --                  AND Tenants.Telephone LIKE CASE
    --                                                 WHEN @Telephone IS NULL
    --                                                 THEN Tenants.Telephone
    --                                                 ELSE '%' + @Telephone + '%'
    --                                             END
    AND Properties.PropertiesId = CASE
      WHEN @PropertyId IS NULL THEN Properties.PropertiesId
      ELSE @PropertyId
    END
    AND Apartments.ApartmentsId = CASE
      WHEN @ApartmentId IS NULL THEN Apartments.ApartmentsId
      ELSE @ApartmentId
    END) AS InnerTable
  ORDER BY InnerTable.Name;
END;


GO