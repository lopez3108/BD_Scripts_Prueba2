SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Last update by JT/02-09-2025 Task 6741 Return bank address
CREATE PROCEDURE [dbo].[sp_GetBankAccounts] @BankId INT = NULL,
@AccountOwnerId INT = NULL,
@AccountNumber VARCHAR(4) = NULL,
@Active BIT = NULL,
@UserId INT = NULL,
@Date DATETIME = NULL
AS
BEGIN
  SET NOCOUNT ON;
  SELECT DISTINCT
    ba.BankAccountId
   ,ba.AccountNumber
   ,ba.BankId
   ,b.Name AS Bank
   ,ao.AccountOwnerId
   ,ao.Name AS AccountOwnerName
   ,CONCAT('**** ', ba.AccountNumber, ' (', b.Name, ')') AS BankNameNumberFormat
   ,ISNULL(c.NumberCards, 0) AS NumberCards
   ,CAST(ISNULL(ba.Active, 1) AS BIT) AS Active
   ,CASE
      WHEN ba.Active = 1 THEN 'ACTIVE'
      ELSE 'INACTIVE'
    END AS ActiveFormat
   ,ba.InitialBalance
   ,ba.FullAccount
   ,ba.FullAccount AS FullAccountSaved
   ,CAST(
    CASE
      WHEN @UserId IS NOT NULL AND
        ba.CreatedBy = @UserId AND
        CAST(ba.CreationDate AS DATE) = CAST(@Date AS DATE) THEN 1
      ELSE 0
    END AS BIT
    ) AS Editable
   ,ba.CreationDate
   ,u.Name AS CreatedBy
    --    ,ab.Address BankAddress
   ,UPPER(ab.Address + ' ' + ZipCodes.City + ', ' + ZipCodes.StateAbre + ', ' + ab.ZipCode) BankAddress
--  ,UPPER('ab.Address') BankAddress

  FROM dbo.BankAccounts ba
  INNER JOIN AddressXBank ab
    ON ab.BankId = ba.BankId
  LEFT JOIN ZipCodes
    ON ZipCodes.ZipCode = ab.ZipCode
  INNER JOIN dbo.BankAccountsXProviderBanks bapb
    ON ba.BankAccountId = bapb.BankAccountId
  INNER JOIN dbo.AccountOwners ao
    ON bapb.AccountOwnerId = ao.AccountOwnerId
  INNER JOIN dbo.Bank b
    ON ba.BankId = b.BankId
  INNER JOIN dbo.Users u
    ON u.UserId = ba.CreatedBy
  LEFT JOIN (SELECT
      BankAccountId
     ,COUNT(*) AS NumberCards
    FROM dbo.CardBanksXBankAccounts
    GROUP BY BankAccountId) c
    ON c.BankAccountId = ba.BankAccountId
  WHERE (@BankId IS NULL
  OR ba.BankId = @BankId)
  AND (@AccountOwnerId IS NULL
  OR ao.AccountOwnerId = @AccountOwnerId)
  AND (@AccountNumber IS NULL
  OR ba.AccountNumber = @AccountNumber)
  AND (@Active IS NULL
  OR ba.Active = @Active)
  ORDER BY ba.AccountNumber;
END;
GO