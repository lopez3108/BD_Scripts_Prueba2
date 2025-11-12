SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-07-24 CB/5972: Available deposit must be 0 if setvalailabledeposit is false
-- 2024-07-30 DJ/5979: Added DepositRefundFee field
-- 2024-08-22 DJ/5974: Checkin info en DB before saving to avoid data overwriting

-- =============================================
-- Author:      JF
-- Create date: 11/10/2024 9:41 p. m.
-- Database:    developing
-- Description: task 6103 Ajustes pdf contract
-- =============================================

-- 2026-09-26 DJ/6771: Error deposit payments

CREATE PROCEDURE [dbo].[sp_GetDepositFinancing]
(@Name         VARCHAR(50) = NULL, 
 @Telephone    VARCHAR(10) = NULL, 
 @PropertiesId INT         = NULL, 
 @ApartmentId  INT         = NULL, 
 @Due          BIT         = NULL, 
@StatusCode VARCHAR (5) = null,
@Date DATETIME = NULL,
@ContractId INT = NULL --5974
)
AS
    BEGIN


	DECLARE @statusClosed INT
	SET @statusClosed = (SELECT TOP 1 ContractStatusId FROM ContractStatus WHERE Code = 'C02')

	DECLARE @statusActive INT
	SET @statusActive = (SELECT TOP 1 ContractStatusId FROM ContractStatus WHERE Code = 'C01')


        SELECT DISTINCT 
               Contract.ContractId, 
               FinancingDeposit,
               --dbo.Contract.TenantId,
               dbo.Contract.AgencyId, 
        (
            SELECT TOP 1 Name FROM [dbo].[FN_GetContractTenantInfo](dbo.Contract.ContractId)
        ) Name, 
        (
            SELECT TOP 1 Telephone FROM [dbo].[FN_GetContractTenantInfo](dbo.Contract.ContractId)
        ) Telephone, 
        (
           SELECT TOP 1 Name FROM [dbo].[FN_GetContractTenantInfo](dbo.Contract.ContractId)
        ) TenantNamePrincpal,
    --dbo.Tenants.Name,
    --dbo.Tenants.Telephone,
               DownPayment, 
               dbo.fn_GetDepositFinancingPaid(Contract.ContractId) AS Paid, 
               dbo.fn_GetDepositFinancingDue(Contract.ContractId) AS Due, 
        (
            SELECT TOP 1 d.Usd
            FROM DepositFinancingPayments d
            WHERE d.ContractId = dbo.Contract.ContractId
            ORDER BY CreationDate DESC
        ) AS LastPaymentUsd, 
        (
            SELECT TOP 1 d.CreationDate
            FROM DepositFinancingPayments d
            WHERE d.ContractId = dbo.Contract.ContractId
            ORDER BY CreationDate DESC
        ) AS LastPaymentOn, 

		 (
            SELECT TOP 1  FORMAT(d.CreationDate , 'MM-dd-yyyy h:mm:ss tt', 'en-US')
            FROM DepositFinancingPayments d
            WHERE d.ContractId = dbo.Contract.ContractId
            ORDER BY CreationDate DESC
        ) AS LastPaymentOnFormat,
        (
            SELECT TOP 1 u.Name
            FROM DepositFinancingPayments d
            INNER JOIN Users u ON d.CreatedBy = u.UserId
            WHERE d.ContractId = dbo.Contract.ContractId
            ORDER BY CreationDate DESC
        ) AS lastPaymentByName, 
		  
               dbo.Contract.SetAvailableDeposit, 
			  ISNULL((SELECT TOP 1 ContractAvailableDeposit FROM [dbo].[FN_GetContractDepositInformation](dbo.Contract.ContractId, @Date)),0)
			  AS AvailableDeposit, 
			   (ISNULL((SELECT TOP 1 ContractAvailableRefund FROM [dbo].[FN_GetContractDepositInformation](dbo.Contract.ContractId, @Date)), 0)) AS RefundAvailable, 
			   ISNULL((select SUM(DepositUsed) from PropertiesBillLabor WHERE ContractId = dbo.Contract.ContractId),0) as BillLabor,
               SetAvailableDeposit, 
               dbo.Apartments.Number,
               dbo.Properties.PersonInChargeTelephone AS CompanyPhone, 
               dbo.Apartments.ApartmentsId, 
               dbo.Properties.PropertiesId, 
               dbo.Properties.Name AS PropertyName, 
               dbo.Properties.Address + ' ' + ZipCodes.City + ' ' + ZipCodes.StateAbre + ' ' + ZipCodes.ZipCode AS PropertyAddress, 
               dbo.ContractStatus.Code AS StatusCode, 
               dbo.ContractStatus.Description AS StatusDescription, 
        (
            SELECT TOP 1 Message
            FROM FinancingMessages
                 INNER JOIN SMSCategories ON SMSCategories.SMSCategoryId = FinancingMessages.SMSCategoryId
            WHERE SMSCategories.Code = 'C18'
        ) AS SMSMessage, 
        (
            SELECT TOP 1 Title
            FROM FinancingMessages
                 INNER JOIN SMSCategories ON SMSCategories.SMSCategoryId = FinancingMessages.SMSCategoryId
            WHERE SMSCategories.Code = 'C18'
        ) AS FinancingMessageTitle, 
        (
            SELECT TOP 1 FinancingMessages.SMSCategoryId
            FROM FinancingMessages
                 INNER JOIN SMSCategories ON SMSCategories.SMSCategoryId = FinancingMessages.SMSCategoryId
            WHERE SMSCategories.Code = 'C18'
        ) AS SMSCategoryId, 
        (
            SELECT TOP 1 FinancingMessageId
            FROM FinancingMessages
                 INNER JOIN SMSCategories ON SMSCategories.SMSCategoryId = FinancingMessages.SMSCategoryId
            WHERE SMSCategories.Code = 'C18'
        ) AS FinancingMessageId,

		(
            SELECT isnull(sum(d.Cash),0)
        FROM DepositFinancingPayments d
				 where d.ContractId = dbo.Contract.ContractId 
        ) AS Cash,
dbo.Contract.DepositBankAccountId,
dbo.Contract.RefundDate,
ISNULL(dbo.Contract.RefundUsd,0) as RefundUsd,
dbo.Contract.DepositRefundFee,
[dbo].[fn_GetDepositRefundTotal](dbo.Contract.ContractId, @Date) as DepositRefundCalculated, --5979
dbo.Contract.StartDate
        FROM dbo.Contract
             INNER JOIN dbo.Apartments ON dbo.Contract.ApartmentId = dbo.Apartments.ApartmentsId
             INNER JOIN dbo.Properties ON dbo.Properties.PropertiesId = dbo.Apartments.PropertiesId
             INNER JOIN dbo.ContractStatus ON dbo.ContractStatus.ContractStatusId = dbo.Contract.STATUS
             INNER JOIN dbo.TenantsXcontracts tc ON TC.ContractId = Contract.ContractId
             INNER JOIN dbo.Tenants ON Tenants.TenantId = TC.TenantId
             --INNER JOIN Tenants ON Tenants.TenantId = Contract.TenantId
             INNER JOIN ZipCodes ON ZipCodes.ZipCode = Properties.Zipcode
        WHERE 
		(@ContractId IS NULL OR
		dbo.Contract.ContractId = @ContractId) AND
		(@StatusCode IS NULL OR
		(@StatusCode = 'C01' AND 
		[dbo].[fn_GetDepositFinancingDue](dbo.Contract.ContractId) > 0 AND dbo.Contract.Status = @statusActive) OR
		(@StatusCode = 'C02' AND 
		dbo.Contract.SetAvailableDeposit = CAST(1 AS BIT) AND dbo.Contract.Status = @statusClosed) OR
		(@StatusCode = 'C03' AND 
		dbo.Contract.RefundDate IS NOT NULL)) AND
		dbo.Contract.DownPayment > 0
              --AND dbo.Contract.RefundDate IS NULL
			  AND (@Name IS NULL OR dbo.Tenants.Name LIKE '%' + @Name + '%')
              AND (@Telephone IS NULL OR  dbo.Tenants.Telephone = @Telephone)
              AND (@ApartmentId IS NULL OR dbo.Contract.ApartmentId = @ApartmentId)
              AND (@PropertiesId IS NULL OR dbo.Apartments.PropertiesId = @PropertiesId)
			  AND (@Date IS NULL OR CAST(dbo.Contract.StartDate as DATE) <= CAST(@Date as DATE))

            
    END;


GO