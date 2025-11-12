SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:11-10-2023
--CAMBIOS EN 5424, Refactoring reporte de cash fund

CREATE FUNCTION [dbo].[fn_CalculateCashFundInitialBalance](
@AgencyId   INT, 
@FromDate   DATETIME = NULL, 
@ToDate     DATETIME = NULL,
@Type INT = NULL)
RETURNS @result TABLE
(     [Index] INT
   ,[Type] VARCHAR(30)
   ,CreationDate DATETIME
   ,[Description] VARCHAR(100)
   ,Usd DECIMAL(18, 2)
)
AS
   BEGIN  
   
 
 -- Cash fund increase
  IF (@Type IS NULL
    OR @Type = 2)
  BEGIN

    INSERT INTO @result
      SELECT
        2
       ,'CASH FUND INCREASE' AS Type
       ,dbo.CashFundModifications.CreationDate
       ,dbo.Users.Name
            ,isnull(DebitCashFund,0) AS Usd
      FROM dbo.CashFundModifications
      INNER JOIN dbo.Cashiers
        ON dbo.CashFundModifications.CashierId = dbo.Cashiers.CashierId
      INNER JOIN dbo.Users
        ON dbo.Cashiers.UserId = dbo.Users.UserId
      WHERE CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)
      AND dbo.CashFundModifications.AgencyId = @AgencyId


  END

  -- Cash fund decrease
  IF (@Type IS NULL
    OR @Type = 3)
  BEGIN

    INSERT INTO @result
      SELECT
        3
       ,'CASH FUND DECREASE' AS Type
       ,dbo.CashFundModifications.CreationDate
       ,dbo.Users.Name
       ,isnull(CreditCashFund,0) AS Usd
 FROM dbo.CashFundModifications
      INNER JOIN dbo.Cashiers
        ON dbo.CashFundModifications.CashierId = dbo.Cashiers.CashierId
      INNER JOIN dbo.Users
        ON dbo.Cashiers.UserId = dbo.Users.UserId
      WHERE CAST(CreationDate AS DATE) >= CAST(@FromDate AS DATE)
      AND CAST(CreationDate AS DATE) <= CAST(@ToDate AS DATE)
      AND dbo.CashFundModifications.AgencyId = @AgencyId


  END
RETURN

--    RETURN ((
--
---- Initial cash fund
----ISNULL((SELECT TOP 1 SUM(NewCashFund) FROM CashFundModifications 
----WHERE AgencyId = @AgencyId AND FirstCashFund = 1),0)
--
--ISNULL((SELECT TOP 1 SUM(OldCashFund - NewCashFund) FROM CashFundModifications 
--WHERE AgencyId = @AgencyId AND CAST(CreationDate as DATE) < CAST(@EndDate as DATE)),0)
--
--
--
--))

END

GO