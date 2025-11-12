SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--CREATED DATE: 29-04-2024
--UPDATE BY: JT
--USO: QUERY TO GET ALL MISSINGS MAKE BY AGENCY, FROM DATE, TO DATE, CODEFILTER= PENDING/RANGE #5785


-- 2025-07-15 JT/6603: Missing payments managers

CREATE FUNCTION [dbo].[FN_GenerateOnyMissingDetailReport] (@AgencyId VARCHAR(100) = NULL,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@CodeFilter VARCHAR(3) = NULL,
@CashierId INT = NULL,
@UserManagerId INT = NULL)
RETURNS @result TABLE (
  --  [Index] INT
  AgencyId INT
 ,AgencyCodeName VARCHAR(1000)
 ,Date DATETIME
 ,Employee VARCHAR(1000)
 ,CashierId INT
 ,Type VARCHAR(1000)
 ,TypeId INT
 ,UserBeneficaryId INT
 ,Usd DECIMAL(18, 2)
 ,Credit DECIMAL(18, 2)
 ,BalanceDetail DECIMAL(18, 2)
)

AS
BEGIN
  INSERT INTO @result
    SELECT
      D.AgencyId
     ,A.Code + ' - ' + A.Name AS AgencyCodeName
     ,CAST(D.CreationDate AS date) AS DATE
     ,u.Name Employee
     ,c.CashierId
     ,'DAILY' Type
     ,1 TypeId
     ,u.UserId UserBeneficaryId
     ,ABS((D.Missing)) AS Usd
     ,0 Credit
     ,ABS((D.Missing)) BalanceDetail
    FROM Daily D
    INNER JOIN Agencies A
      ON A.AgencyId = D.AgencyId
    INNER JOIN Cashiers c
      ON c.CashierId = D.CashierId
    INNER JOIN Users u
      ON u.UserId = c.UserId
--    INNER JOIN dbo.AgenciesxUser ax
--      ON ax.UserId = u.UserId
    WHERE (
    d.AgencyId IN (SELECT
        item
      FROM dbo.FN_ListToTableInt(@AgencyId))
    OR @AgencyId IS NULL)
      AND (d.AgencyId IN ((SELECT
        axm.AgencyId
      FROM Users um
      INNER JOIN dbo.AgenciesxUser axm
        ON axm.UserId = um.UserId WHERE um.UserId = @UserManagerId))
    OR @UserManagerId IS NULL)
    AND D.Missing < 0
    AND (D.CashierId = @CashierId
    OR @CashierId IS NULL)
    AND ((@CodeFilter = 'C02' --DATE RANGES
    AND (CAST(D.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(D.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL))
    OR ((@CodeFilter = 'C01' --PENDINGS
    AND (SELECT
        [dbo].FN_GenerateBalanceMissing(A.AgencyId, D.CashierId, @ToDate, D.DailyId, @UserManagerId))
    <> 0)))
  RETURN;
END;


GO