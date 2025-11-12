SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-08-07 DJ/5991: Added payment type to deposit refund operation

CREATE PROCEDURE [dbo].[sp_GetContractBankAccounts] 
										   @ContractId INT
AS
    BEGIN

SELECT DISTINCT * FROM (
	SELECT 
	bp.BankAccountId as BankAccountId, 
               bp.AccountNumber as AccountNumber, 
               bp.BankId as BankId, 
               b.Name AS Bank, 
               ('**** ' + bp.AccountNumber + ' ' +  '(' + b.Name + ')') AS BankNameNumberFormat
	
	FROM dbo.Contract c
	INNER JOIN dbo.Apartments a ON a.ApartmentsId = c.ApartmentId
	INNER JOIN dbo.Properties p ON p.PropertiesId = a.PropertiesId
	LEFT JOIN dbo.BankAccounts bp ON bp.BankAccountId = p.BankAccountId
	LEFT JOIN dbo.Bank b ON b.BankId = bp.BankId
	WHERE c.ContractId = @ContractId

	UNION ALL
		SELECT 
	br.BankAccountId as BankAccountId, 
               br.AccountNumber as AccountNumber, 
               br.BankId as BankId, 
               b.Name AS Bank, 
               ('**** ' + br.AccountNumber + ' ' +  '(' + b.Name + ')') AS BankNameNumberFormat
	FROM dbo.Contract c
	LEFT JOIN dbo.BankAccounts br ON br.BankAccountId = c.DepositBankAccountId
	LEFT JOIN dbo.Bank b ON b.BankId = br.BankId
	WHERE c.ContractId = @ContractId
        
        )  AS Q ORDER BY AccountNumber
    END;
GO