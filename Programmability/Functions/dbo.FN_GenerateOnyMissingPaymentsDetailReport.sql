SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--CREATED DATE: 29-04-2024
--UPDATE BY: JT
--USO: QUERY TO GET ALL MISSINGS PAYMENTS MAKE BY AGENCY, FROM DATE, TO DATE, CODEFILTER= PENDING/RANGE #5785

-- 2025-06-27 DJ/6603: Missing payments managers
-- 2025-07-15 JT/6603: Missing payments managers

CREATE FUNCTION [dbo].[FN_GenerateOnyMissingPaymentsDetailReport] (@AgencyId VARCHAR(100) = NULL,
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
 ,DatePyament DATETIME
 ,OtherPaymentId INT
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
      o.AgencyId
     ,A.Code + ' - ' + A.Name AS AgencyCodeName
     ,CAST(d.CreationDate AS date) AS DATE
     ,CAST(o.CreationDate AS DATETIME) DatePyament
     ,o.OtherPaymentId
     ,CASE
        WHEN UPPER(umissing.Name) <> UPPER(userPayment.Name) THEN umissing.Name + ' PAID BY: ' + userPayment.Name
        ELSE umissing.Name
      END [Employee]
     ,C.CashierId
     ,'PAYMENT-' + FORMAT(o.CreationDate, 'MM-dd-yyyy', 'en-US') Type
     ,2 TypeId
     ,userPayment.UserId UserBeneficaryId
     ,0 Usd
     ,ABS((ISNULL(o.UsdPayMissing, 0))) Credit
     ,ABS((ISNULL(o.UsdPayMissing, 0))) BalanceDetail
    FROM OtherPayments o
    INNER JOIN Agencies A
      ON A.AgencyId = o.AgencyId
    INNER JOIN Daily d
      ON o.DailyId = d.DailyId
    INNER JOIN Cashiers C
      ON d.CashierId = C.CashierId
    INNER JOIN Users umissing
      ON umissing.UserId = C.UserId
    INNER JOIN Users userPayment
      ON userPayment.UserId = o.CreatedBy
    --    INNER JOIN dbo.AgenciesxUser ax
    --      ON ax.UserId = umissing.UserId
    WHERE (
    o.AgencyId IN (SELECT
        item
      FROM dbo.FN_ListToTableInt(@AgencyId))
    OR @AgencyId IS NULL)
    AND (o.AgencyId IN ((SELECT
        axm.AgencyId
      FROM Users um
      INNER JOIN dbo.AgenciesxUser axm
        ON axm.UserId = um.UserId WHERE um.UserId = @UserManagerId))
    OR @UserManagerId IS NULL)
    AND CAST(o.PayMissing AS BIT) = 1
    AND (d.CashierId = @CashierId
    OR @CashierId IS NULL)
    AND ((@CodeFilter = 'C02' --DATE RANGES
    AND (CAST(d.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(d.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL))
    OR ((@CodeFilter = 'C01' --PENDINGS
    AND (SELECT
        [dbo].FN_GenerateBalanceMissing(A.AgencyId, d.CashierId, @ToDate, d.DailyId, @UserManagerId))
    <> 0)))

    ORDER BY CAST(d.CreationDate AS date), FORMAT(o.CreationDate, 'MM-dd-yyyy', 'en-US')
  RETURN;
END;


GO