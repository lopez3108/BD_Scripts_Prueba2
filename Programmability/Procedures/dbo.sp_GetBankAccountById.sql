SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetBankAccountById] @BankAccountId         INT    
AS
    BEGIN
        SELECT 
		b.BankAccountId ,
		b.AccountNumber,
		ba.Name
		FROM BankAccounts b INNER JOIN Bank ba ON ba.BankId = b.BankId
		WHERE b.BankAccountId = @BankAccountId
    END;

GO