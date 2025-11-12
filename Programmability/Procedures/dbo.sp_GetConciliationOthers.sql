SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--CreationOn 29-05-2024, CreationBY JF, task 5854 Permitir editar la agencia a los expenses bank 
--Last update by JT/23-06-2025 TASK 6617 Permitir completar varios expenses bank
--Last update by JT/22-07-2025 TASK 6617 Permitir editar expenses bank en pending

CREATE PROCEDURE [dbo].[sp_GetConciliationOthers] @ConciliationOtherTypeId INT = NULL,
@BankAccountId INT = NULL,
@AgencyId INT = NULL,
@BankId INT = NULL,
@IsCredit BIT = NULL,
@DateFrom DATETIME = NULL,
@DateTo DATETIME = NULL,
@Status VARCHAR(50) = NULL,
@ListAgenciId VARCHAR(500) = NULL
AS
BEGIN

  SELECT
    dbo.ConciliationOthers.ConciliationOtherId
   ,dbo.ConciliationOthers.AgencyId
   ,CASE
      WHEN AgencyId IS NULL THEN 'N/A'
      ELSE (SELECT
            dbo.Agencies.Code + ' - ' + dbo.Agencies.Name
          FROM dbo.Agencies
          WHERE dbo.Agencies.AgencyId = dbo.ConciliationOthers.AgencyId)
    END AS AgencyName
   ,CASE
      WHEN AgencyId IS NULL THEN 'N/A'
      ELSE (SELECT
            --      dbo.Agencies.Code + ' - ' + dbo.Agencies.Name
            dbo.Agencies.Name
          FROM dbo.Agencies
          WHERE dbo.Agencies.AgencyId = dbo.ConciliationOthers.AgencyId)
    END AS Name
   ,CASE
      WHEN AgencyId IS NULL THEN ''
      ELSE (SELECT
            --            dbo.Agencies.Code + ' - ' + dbo.Agencies.Name
            dbo.Agencies.Code
          FROM dbo.Agencies
          WHERE dbo.Agencies.AgencyId = dbo.ConciliationOthers.AgencyId)
    END AS AgencyCode
   ,dbo.ConciliationOthers.BankAccountId
   ,dbo.BankAccounts.AccountNumber
   ,dbo.Bank.BankId
   ,dbo.Bank.Name AS BankName
   ,dbo.ConciliationOthers.Date
   ,FORMAT(ConciliationOthers.Date, 'MM-dd-yyyy ', 'en-US') DateFormat
   ,dbo.ConciliationOthers.IsCredit
   ,dbo.ConciliationOthers.Usd
   ,ebs.Name AS Status
   ,ebs.Code AS CodeStatus
   ,dbo.ConciliationOthers.CreatedBy
   ,dbo.Users.Name AS CreatedByName
   ,dbo.ConciliationOthers.CreationDate
   ,FORMAT(ConciliationOthers.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat
   ,CASE
      WHEN dbo.ConciliationOthers.IsCredit = 1 THEN ' DEBIT'
      ELSE ' CREDIT'
    END AS 'Type1'
   ,CASE
      WHEN dbo.ConciliationOthers.IsCredit = 1 THEN ' CREDIT'
      ELSE ' DEBIT'
    END AS 'Type2'
   ,dbo.ConciliationOthers.ConciliationOtherTypeId
   ,dbo.ConciliationOtherTypes.Code
   ,dbo.ConciliationOtherTypes.Description AS OtherTypeName
   ,dbo.ConciliationOthers.Description
   ,dbo.ConciliationOthers.InterestUsd
   ,dbo.ConciliationOthers.CapitalUsd
   ,UC.Name AS ComletedByName
   ,dbo.ConciliationOthers.CreationDate
   ,FORMAT(ConciliationOthers.CompletedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CompletedOnFormat
   ,FORMAT(LastUpdatedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US') LastUpdatedOnFormat
   ,ul.Name AS LastUpdatedByName
  FROM dbo.ConciliationOthers
  INNER JOIN dbo.BankAccounts
    ON dbo.ConciliationOthers.BankAccountId = dbo.BankAccounts.BankAccountId
  INNER JOIN dbo.Bank
    ON dbo.BankAccounts.BankId = dbo.Bank.BankId
  INNER JOIN dbo.Users
    ON dbo.Users.UserId = dbo.ConciliationOthers.CreatedBy
  LEFT JOIN dbo.Users UC
    ON UC.UserId = dbo.ConciliationOthers.CompletedBy
      LEFT JOIN Users ul ON Ul.UserId = ConciliationOthers.LastUpdatedBy
  INNER JOIN dbo.ConciliationOtherTypes
    ON dbo.ConciliationOthers.ConciliationOtherTypeId = dbo.ConciliationOtherTypes.ConciliationOtherTypeId
  INNER JOIN dbo.ExpenseBankStatus ebs
    ON dbo.ConciliationOthers.ExpenseBankStatusId = ebs.ExpenseBankStatusId
  WHERE (@ListAgenciId IS NULL
  OR dbo.ConciliationOthers.AgencyId IN (SELECT
      item
    FROM dbo.FN_ListToTableInt(@ListAgenciId))
  )
  AND (ebs.Code = @Status
  OR @Status IS NULL)
  AND dbo.ConciliationOthers.ConciliationOtherTypeId = CASE
    WHEN @ConciliationOtherTypeId IS NULL THEN dbo.ConciliationOthers.ConciliationOtherTypeId
    ELSE @ConciliationOtherTypeId
  END
  AND dbo.BankAccounts.BankAccountId = CASE
    WHEN @BankAccountId IS NULL THEN dbo.BankAccounts.BankAccountId
    ELSE @BankAccountId
  END
  AND dbo.Bank.BankId = CASE
    WHEN @BankId IS NULL THEN dbo.Bank.BankId
    ELSE @BankId
  END
  AND dbo.ConciliationOthers.IsCredit = CASE
    WHEN @IsCredit IS NULL THEN dbo.ConciliationOthers.IsCredit
    ELSE @IsCredit
  END
  AND CAST(dbo.ConciliationOthers.CreationDate AS DATE) >= CASE
    WHEN @DateFrom IS NULL THEN CAST(dbo.ConciliationOthers.CreationDate AS DATE)
    ELSE CAST(@DateFrom AS DATE)
  END
  AND CAST(dbo.ConciliationOthers.CreationDate AS DATE) <= CASE
    WHEN @DateTo IS NULL THEN CAST(dbo.ConciliationOthers.CreationDate AS DATE)
    ELSE CAST(@DateTo AS DATE)
  END
  ORDER BY dbo.ConciliationOthers.CreationDate DESC

END







GO