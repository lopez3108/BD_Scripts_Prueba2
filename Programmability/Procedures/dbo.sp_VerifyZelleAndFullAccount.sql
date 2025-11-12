SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-07-24 DJ/5973: Adding ZelleEmail field

CREATE PROCEDURE [dbo].[sp_VerifyZelleAndFullAccount] (@PropertiesId INT)
AS
  BEGIN
    IF EXISTS (SELECT
          p.PropertiesId
        FROM Properties p
        left JOIN BankAccounts ba ON  P.BankAccountId = BA.BankAccountId
        WHERE p.PropertiesId = @PropertiesId AND ((p.Zelle is NOT NULL AND p.Zelle != '') 
		or (BA.FullAccount IS NOT NULL AND ba.FullAccount != '' AND LEN(ba.FullAccount) >= 4  AND LEN(ba.FullAccount) <= 16  )))
    BEGIN
     SELECT
          p.Zelle,
		  p.ZelleEmail,
          BA.FullAccount,
          dbo.Bank.BankId, 
dbo.Bank.Name AS BankName ,
   ba.AccountNumber,
      dbo.AccountOwners.Name AS AccountOwnerName,
	  p.Name as PropertyName
          FROM Properties p
           LEFT JOIN dbo.BankAccountsXProviderBanks ON P.BankAccountId = dbo.BankAccountsXProviderBanks.BankAccountId
           LEFT JOIN dbo.AccountOwners ON dbo.BankAccountsXProviderBanks.AccountOwnerId = dbo.AccountOwners.AccountOwnerId
           LEFT OUTER JOIN dbo.BankAccounts ba ON p.BankAccountId = ba.BankAccountId
           LEFT JOIN dbo.Bank ON ba.BankId = dbo.Bank.BankId
       
        WHERE p.PropertiesId = @PropertiesId AND (p.Zelle is NOT NULL or BA.FullAccount IS NOT NULL )
    END
   

  END;
GO