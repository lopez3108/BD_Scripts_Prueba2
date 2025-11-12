SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllConciliationSalesTaxes] @AgencyId INT = NULL,
@ToDate DATE = NULL,
@FromDate DATE = NULL,
@IsCredit BIT = NULL,
@BankAccountId INT = NULL
AS
BEGIN
  SELECT
    ct.*
   ,FORMAT(ct.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat
   ,FORMAT(ct.Date, 'MM-dd-yyyy', 'en-US') DateSalestaxFormat
   ,FORMAT(ct.FromDate, 'MM-dd-yyyy', 'en-US') FromDateFormat
   ,FORMAT(ct.ToDate, 'MM-dd-yyyy ', 'en-US') ToDateFormat
   ,A.Code + ' - ' + A.Name AgencyName
   ,u.Name CreatedByName
   ,ba.AccountNumber
   ,b.Name BankName
   ,A.Code + ' - ' + A.Name AS AgencyCodeName
   ,CASE
      WHEN ct.IsCredit = 1 THEN ' CREDIT'
      ELSE ' DEBIT'
    END AS IsCreditDescription
   ,CASE
      WHEN ct.IsCredit = 1 THEN ' DEBIT'
      ELSE ' CREDIT'
    END AS OperationType

  FROM ConciliationSalesTaxes ct
  INNER JOIN Agencies A
    ON A.AgencyId = ct.AgencyId
  INNER JOIN Users u
    ON u.UserId = ct.CreatedBy
  INNER JOIN BankAccounts ba
    ON ba.BankAccountId = ct.BankAccountId
  INNER JOIN Bank b
    ON b.BankId = ba.BankId
  WHERE (ct.AgencyId = @AgencyId
  OR @AgencyId IS NULL)
  AND (IsCredit = @IsCredit
  OR @IsCredit IS NULL)
  AND (ct.BankAccountId = @BankAccountId
  OR @BankAccountId IS NULL)
  AND ((@FromDate IS NULL)
  OR (CAST(ct.CreationDate AS DATE) >= CAST(@FromDate AS DATE)))
  AND ((@ToDate IS NULL)
  OR (CAST(ct.CreationDate AS DATE) <= CAST(@ToDate AS DATE))
  )
  ORDER BY ct.CreationDate DESC



END;


GO