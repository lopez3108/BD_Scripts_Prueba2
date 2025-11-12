SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:11-10-2023
--CAMBIOS EN 5424, Refactoring reporte de cash fund

CREATE FUNCTION [dbo].[fn_GenerateCashFundReport] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@Type INT = NULL)
RETURNS @result TABLE (
  [Index] INT
 ,[Type] VARCHAR(30)
 ,CreationDate DATETIME
 ,[Description] VARCHAR(100)
 ,Debit DECIMAL(18, 2)
 ,Credit DECIMAL(18, 2)
 ,Balance DECIMAL(18, 2)
)
AS
BEGIN
-- Cash fund INCREASE es aumento y es crédito  jt task 5441
  IF (@Type IS NULL
    OR @Type = 2)
  BEGIN

    INSERT INTO @result
      SELECT
        2
       ,'CASH FUND INCREASE' AS Type
       ,dbo.CashFundModifications.CreationDate
       ,dbo.Users.Name
       ,0 debit
       ,ISNULL(SUM(CreditCashFund),0) Credit
       ,-ISNULL(SUM(CreditCashFund),0) AS Balance
      FROM dbo.CashFundModifications
      INNER JOIN dbo.Cashiers
        ON dbo.CashFundModifications.CashierId = dbo.Cashiers.CashierId
      INNER JOIN dbo.Users
        ON dbo.Cashiers.UserId = dbo.Users.UserId
      WHERE
      CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)
      AND 
      dbo.CashFundModifications.AgencyId = @AgencyId
      GROUP BY dbo.CashFundModifications.CreationDate
              ,dbo.Users.Name
              ,CashFundModificationsId
END
  -- Cash fund  DECREASE es menos y es débito  jt task 5441
  IF (@Type IS NULL
    OR @Type = 3)
  BEGIN

    INSERT INTO @result
      SELECT
        3
       ,'CASH FUND DECREASE' AS Type
       ,dbo.CashFundModifications.CreationDate
       ,dbo.Users.Name        
        ,SUM(isnull(DebitCashFund,0))  AS Debit
       ,0 Credit
       ,SUM(isnull(DebitCashFund,0)) AS Balance
      FROM dbo.CashFundModifications
      INNER JOIN dbo.Cashiers
        ON dbo.CashFundModifications.CashierId = dbo.Cashiers.CashierId
      INNER JOIN dbo.Users
        ON dbo.Cashiers.UserId = dbo.Users.UserId
      WHERE CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)
      AND dbo.CashFundModifications.AgencyId = @AgencyId
      GROUP BY dbo.CashFundModifications.CreationDate
              ,dbo.Users.Name
              ,CashFundModificationsId

  END

  
  RETURN
END
GO