SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-04-10 DJ/5781: Changed description por operations
-- 2024-04-22 JF/5811: Generate expense daily after paying payroll

CREATE PROCEDURE [dbo].[sp_GetAllExpensesByStateValidated] @ListAgenciId VARCHAR(500) = NULL,
@Validated BIT = NULL,
@FromDate DATE = NULL,
@ToDate DATE = NULL
AS

BEGIN
  IF OBJECT_ID('#TempTableExpense') IS NOT NULL
  BEGIN
    DROP TABLE #TempTableExpense;
  END;
  CREATE TABLE #TempTableExpense (
    RowNumber INT
   ,ExpenseId INT
   ,[Description] VARCHAR(1000)
   ,Usd DECIMAL(18, 2)
   ,AgencyId INT
   ,CreatedBy INT
   ,CreatedOn DATETIME
   ,CreatedOnFormat VARCHAR(60)
   ,moneyvalue DECIMAL(18, 2)
   ,[Value] DECIMAL(18, 2)
   ,OnlyNegative BIT
   ,AcceptNegative BIT
   ,[Set] BIT
   ,ExpenseTypeId INT
   ,ExpenseTypeCode VARCHAR(4)
   ,ExpenseTypeDescripcion VARCHAR(50)
   ,BillTypeId INT
   ,MonthsId INT
   ,ProviderName VARCHAR(50)
   ,ProviderId INT
   ,Company VARCHAR(50)
   ,TransactionNumber VARCHAR(15)
   ,Sender VARCHAR(50)
   ,Recipient VARCHAR(50)
   ,Quantity INT
   ,MoneyOrderNumber VARCHAR(20)
   ,Validated BIT
   ,[Status] VARCHAR(15)
   ,Cashier VARCHAR(1000)
   ,AgencyName VARCHAR(1000)
   ,FileIdNameExpenses VARCHAR(1000)
   ,ValidatedByName VARCHAR(1000)
   ,ValidatedOnFormat VARCHAR(60)
   ,ValidatedOn DATETIME
  );
  INSERT INTO #TempTableExpense (RowNumber,
  ExpenseId,
  Description,
  Usd,
  AgencyId,
  CreatedBy,
  CreatedOn,
  CreatedOnFormat,
  moneyvalue,
  Value,
  OnlyNegative,
  AcceptNegative,
  [Set],
  ExpenseTypeId,
  ExpenseTypeCode,
  ExpenseTypeDescripcion,
  BillTypeId,
  MonthsId,
  ProviderName,
  ProviderId,
  Company,
  TransactionNumber,
  Sender,
  Recipient,
  Quantity,
  MoneyOrderNumber,
  Validated,
  [Status],
  Cashier,
  AgencyName,
  FileIdNameExpenses,
  ValidatedByName,
  ValidatedOnFormat,
  ValidatedOn)
    SELECT
      *
    FROM (SELECT
        ROW_NUMBER() OVER (
        ORDER BY CAST(Query.CreatedOn AS DATE) DESC) RowNumber
       ,*
      FROM (SELECT
          ExpenseId
         ,Description
         ,Usd
         ,AgencyId
         ,CreatedBy
         ,CreatedOn
         ,FORMAT(CreatedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreatedOnFormat
         ,moneyvalue
         ,Value
         ,OnlyNegative
         ,AcceptNegative
         ,[Set]
         ,ExpenseTypeId
         ,ExpenseTypeCode
         ,ExpenseTypeDescripcion
         ,BillTypeId
         ,MonthsId
         ,ProviderName
         ,ProviderId
         ,Company
         ,TransactionNumber
         ,Sender
         ,Recipient
         ,Quantity
         ,MoneyOrderNumber
         ,Validated
         ,[Status]
         ,Cashier
         ,AgencyName
         ,FileIdNameExpenses
         ,ValidatedByName
         ,FORMAT(ValidatedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US') ValidatedOnFormat
         ,ValidatedOn
        FROM (SELECT
            E.ExpenseId
           ,CASE
              WHEN EY.Code = 'C01' THEN -- Bills
                b.Description + ' ' + m.Description + ' ' + CAST(E.Year AS VARCHAR(4))
              WHEN EY.Code = 'C02' THEN -- Rent
                --'RENT' + ' ' +
                m.Description + ' ' + CAST(E.Year AS VARCHAR(4))
              WHEN EY.Code = 'C03' THEN -- Phone cards
                E.ProviderName -- + ' (PHONE CARDS)'
              WHEN EY.Code = 'C04' THEN -- Phone and accesories
                E.ProviderName -- + ' (PHONE AND ACCESORIES)'
              WHEN EY.Code = 'C05' THEN -- Cleaning instruments
                E.ProviderName -- + ' (CLEANING INSTRUMENTS)'
              WHEN EY.Code = 'C06' THEN -- Food
                E.ProviderName -- + ' (FOOD)'
              WHEN EY.Code = 'C07' THEN -- MT
                E.TransactionNumber + ' ' + E.Recipient -- + ' (MT)'
              WHEN EY.Code = 'C09' THEN -- Cash
                E.Recipient -- + ' (CASH)'
              WHEN EY.Code = 'C10' THEN -- Cashier commissions
                uc.[Name] + ' ' + m.Description + ' ' + CAST(E.Year AS VARCHAR(4)) -- + ' (COMMISSIONS)'
              WHEN EY.Code = 'C11' THEN -- Marketing
                E.Company -- + ' (MARKETING)'
              WHEN EY.Code = 'C12' THEN -- Permit (7 AND 90 DAYS)
                'PERMIT (7 AND 90 DAYS)' -- + E.MoneyOrderNumber
              WHEN EY.Code = 'C13' THEN -- Others
                E.[Description]
              WHEN EY.Code = 'C14' THEN -- Refund
                ur.[Name] + ' ' + CONVERT(VARCHAR(10), E.RefundSurplusDate, 101) + ' ' + E.Description
                 WHEN EY.Code = 'C16' THEN -- Payroll
                'PAYROLL' + ' ' + E.Description

              ELSE CASE
                  WHEN E.Description IS NULL OR
                    E.Description = '' THEN EY.Description
                  ELSE E.Description
                END
            END AS [Description]
           ,E.Usd
           ,E.AgencyId
           ,E.CreatedBy
           ,E.CreatedOn
           ,E.Usd 'moneyvalue'
           ,E.Usd 'Value'
           ,'true' 'OnlyNegative'
           ,'true' 'AcceptNegative'
           ,'true' 'Set'
           ,E.ExpenseTypeId
           ,EY.Code ExpenseTypeCode
           ,ey.Description ExpenseTypeDescripcion
           ,E.BillTypeId
           ,E.MonthsId
           ,E.Year
           ,E.ProviderName
           ,E.ProviderId
           ,E.Company
           ,E.TransactionNumber
           ,E.Sender
           ,E.Recipient
           ,E.Quantity
           ,E.MoneyOrderNumber
           ,E.Validated
           ,CASE
              WHEN E.Validated = 1 THEN 'COMPLETED'
              ELSE 'PENDING'
            END AS [Status]
           ,u.Name Cashier
           ,a.Code + ' - ' + a.Name AgencyName
           ,E.FileIdNameExpenses
           ,uv.Name AS ValidatedByName
           ,E.ValidatedOn
          FROM Expenses E
          INNER JOIN Agencies a
            ON E.AgencyId = a.AgencyId
          INNER JOIN Users u
            ON E.CreatedBy = u.UserId
          LEFT JOIN Users uv
            ON E.ValidatedBy = uv.UserId
          INNER JOIN ExpensesType EY
            ON EY.ExpensesTypeId = E.ExpenseTypeId
          LEFT JOIN dbo.BillTypes b
            ON b.BillTypeId = E.BillTypeId
          LEFT JOIN dbo.Months m
            ON m.MonthId = E.MonthsId
          LEFT JOIN dbo.Providers p
            ON p.ProviderId = E.ProviderId
          LEFT JOIN dbo.Cashiers ca
            ON ca.CashierId = E.CashierId
          LEFT JOIN dbo.Users uc
            ON uc.UserId = ca.UserId
          LEFT JOIN dbo.Cashiers cr
            ON cr.CashierId = E.RefundCashierId
          LEFT JOIN dbo.Users ur
            ON ur.UserId = cr.UserId
          WHERE
          --e.AgencyId = @AgencyId
          (E.Validated = @Validated
          OR @Validated IS NULL)
          AND (E.AgencyId IN (SELECT
              item
            FROM dbo.FN_ListToTableInt(@ListAgenciId))
          OR @ListAgenciId IS NULL)
          AND ((CAST(E.CreatedOn AS DATE) >= CAST(@FromDate AS DATE)
          OR @FromDate IS NULL)
          AND (CAST(E.CreatedOn AS DATE) <= CAST(@ToDate AS DATE))
          OR @ToDate IS NULL)
        --ORDER BY E.Validated ASC
        ) AS QueryAnindado
        GROUP BY ExpenseId
                ,Description
                ,Usd
                ,AgencyId
                ,CreatedBy
                ,CreatedOn
                ,moneyvalue
                ,Value
                ,OnlyNegative
                ,AcceptNegative
                ,[Set]
                ,ExpenseTypeId
                ,ExpenseTypeCode
                ,ExpenseTypeDescripcion
                ,BillTypeId
                ,MonthsId
                ,ProviderName
                ,ProviderId
                ,Company
                ,TransactionNumber
                ,Sender
                ,Recipient
                ,Quantity
                ,MoneyOrderNumber
                ,Validated
                ,[Status]
                ,Cashier
                ,AgencyName
                ,FileIdNameExpenses
                ,ValidatedByName
                ,ValidatedOn) AS Query) AS QueryFinal;
  SELECT
    *
   ,(SELECT
        SUM(t2.USD)
      FROM #TempTableExpense t2
      WHERE t2.RowNumber <= t1.RowNumber)
    BalanceFinal
  FROM #TempTableExpense t1
  ORDER BY RowNumber ASC;
END;
GO