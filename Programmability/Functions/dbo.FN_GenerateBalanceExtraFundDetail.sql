SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:18-10-2023
--CAMBIOS EN 5418, Refactoring reporte de extra fund

CREATE FUNCTION [dbo].[FN_GenerateBalanceExtraFundDetail] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@TypeReport AS INT = NULL) --1 = INITIAL BALANDE 2= ANOTHER

RETURNS @result TABLE
(  [Index] INT
   ,ExtraFundId INT
   ,AgencyId INT
   ,Date DATETIME
   ,Type VARCHAR(1000)
   ,Description VARCHAR(1000)
   ,TypeId INT
   ,Debit DECIMAL(18, 2)
   ,Credit DECIMAL(18, 2)
   ,BalanceDetail DECIMAL(18, 2)
)


AS
     BEGIN
     INSERT INTO @result
SELECT
        ROW_NUMBER() OVER (
        ORDER BY Query.ExtraFundId ASC,
        Query.TypeId ASC,
        CAST(Query.Date AS Date) ASC) [Index]
       ,*
      FROM (SELECT
          E.ExtraFundId
         ,E.AgencyId
         ,E.CreationDate Date
         ,'CASHIERS FROM CASHIERS' AS Type
         ,U.Name Description
         ,1 TypeId
         ,E.Usd Debit
         ,0 Credit
         ,E.Usd BalanceDetail
        FROM ExtraFund E
        INNER JOIN Users U
          ON U.UserId = E.AssignedTo
        LEFT JOIN Cashiers c
          ON U.UserId = c.UserId
        WHERE E.IsCashier = 1
        AND E.AgencyId = @AgencyId
        AND (CAST(E.CreationDate AS Date) >= CAST(@FromDate AS Date)
        OR @FromDate IS NULL)
        AND (CAST(E.CreationDate AS Date) <= CAST(@ToDate AS Date)
        OR @ToDate IS NULL)
        UNION ALL
        SELECT
          E.ExtraFundId
         ,E.AgencyId
         ,E.CreationDate Date
         ,'CASHIERS TO CASHIERS' AS Type
         ,U.Name Description
         ,2 TypeId
         ,0 Debit
         ,E.Usd Credit
         ,-E.Usd BalanceDetail
        FROM ExtraFund E
        INNER JOIN Users U
          ON U.UserId = E.CreatedBy
        LEFT JOIN Cashiers c
          ON U.UserId = c.UserId
        WHERE E.IsCashier = 1
        AND E.AgencyId = @AgencyId
        AND (CAST(E.CreationDate AS Date) >= CAST(@FromDate AS Date)
        OR @FromDate IS NULL)
        AND (CAST(E.CreationDate AS Date) <= CAST(@ToDate AS Date)
        OR @ToDate IS NULL)

        UNION ALL
        SELECT
          E.ExtraFundId
         ,E.AgencyId
         ,E.CreationDate Date
         ,'ADMIN FROM CASHIERS' AS Type
         ,U.Name Description
         ,1 TypeId
         ,E.Usd Debit
         ,0 Credit
         ,E.Usd BalanceDetail
        FROM ExtraFund E
        INNER JOIN Users U
          ON U.UserId = E.AssignedTo
        LEFT JOIN Cashiers c
          ON U.UserId = c.UserId
        WHERE E.CashAdmin = 1
        AND E.AgencyId = @AgencyId
        AND (CAST(E.CreationDate AS Date) >= CAST(@FromDate AS Date)
        OR @FromDate IS NULL)
        AND (CAST(E.CreationDate AS Date) <= CAST(@ToDate AS Date)
        OR @ToDate IS NULL)

        UNION ALL
        SELECT
          E.ExtraFundId
         ,E.AgencyId
         ,E.CreationDate Date
         ,'CASHIERS TO ADMIN' AS Type
         ,U.Name Description
         ,2 TypeId
         ,0 Debit
         ,E.Usd Credit
         ,-E.Usd BalanceDetail
        FROM ExtraFund E
        INNER JOIN Users U
          ON U.UserId = E.CreatedBy
        LEFT JOIN Cashiers c
          ON U.UserId = c.UserId
        WHERE E.CashAdmin = 1
        AND E.AgencyId = @AgencyId
        AND (CAST(E.CreationDate AS Date) >= CAST(@FromDate AS Date)
        OR @FromDate IS NULL)
        AND (CAST(E.CreationDate AS Date) <= CAST(@ToDate AS Date)
        OR @ToDate IS NULL)

        UNION ALL
        SELECT
          E.ExtraFundId
         ,E.AgencyId
         ,E.CreationDate Date
         ,'CASHIERS FROM ADMIN' AS Type
         ,U.Name Description
         ,1 TypeId
         ,E.Usd Debit
         ,0 Credit
         ,E.Usd BalanceDetail
        FROM ExtraFund E
        INNER JOIN Users U
          ON U.UserId = E.AssignedTo
        LEFT JOIN Cashiers c
          ON U.UserId = c.UserId
        WHERE E.CashAdmin = 0
        AND E.IsCashier = 0
        AND E.AgencyId = @AgencyId
        AND (CAST(E.CreationDate AS Date) >= CAST(@FromDate AS Date)
        OR @FromDate IS NULL)
        AND (CAST(E.CreationDate AS Date) <= CAST(@ToDate AS Date)
        OR @ToDate IS NULL)

        UNION ALL
        SELECT
          E.ExtraFundId
         ,E.AgencyId
         ,E.CreationDate Date
         ,'ADMIN TO CASHIERS' AS Type
         ,U.Name Description
         ,2 TypeId
         ,0 Debit
         ,E.Usd Credit
         ,-E.Usd BalanceDetail
        FROM ExtraFund E
        INNER JOIN Users U
          ON U.UserId = E.CreatedBy
        LEFT JOIN Cashiers c
          ON U.UserId = c.UserId
        WHERE E.CashAdmin = 0
        AND E.IsCashier = 0
        AND E.AgencyId = @AgencyId
        AND (CAST(E.CreationDate AS Date) >= CAST(@FromDate AS Date)
        OR @FromDate IS NULL)
        AND (CAST(E.CreationDate AS Date) <= CAST(@ToDate AS Date)
        OR @ToDate IS NULL)) AS Query
     RETURN
     END
GO