SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: Felipe
--LASTUPDATEDON:02-11-2023

CREATE FUNCTION [dbo].[FN_GetReportOtherPaymentDetail] (@AgencyId INT, @FromDate DATETIME = NULL, @ToDate DATETIME = NULL)
RETURNS @result TABLE (
  RowNumber INT
 ,OtherPaymentId INT
 ,AgencyId INT
 ,Date DATETIME
 ,Type VARCHAR(1000)
 ,Description VARCHAR(1000)
 ,NameEmployee VARCHAR(80)
 ,TypeId INT
 ,Usd DECIMAL(18, 2)
 ,Credit DECIMAL(18, 2)
 ,BalanceDetail DECIMAL(18, 2)
)


AS
BEGIN

  INSERT INTO @result


    SELECT
      *
    FROM (SELECT
        ROW_NUMBER() OVER (ORDER BY Query.TypeId ASC, CAST(Query.Date AS Date) ASC) RowNumber
       ,*
      FROM (SELECT
          E.OtherPaymentId
         ,E.AgencyId
         ,E.CreationDate Date
         ,'CLOSING DAILY' Type
         ,CASE
            WHEN E.PayMissing = 1 THEN 'PAY MISSING'
            ELSE SUBSTRING(E.Description, 1, 150) -- cambio de caracteres de 20 a 150 sergio 4-06-2024 task 5891
          END AS Description
         ,U.Name
         ,1 TypeId
         ,CASE
            WHEN E.PayMissing = 1 THEN ISNULL(E.UsdPayMissing, 0)
            ELSE ISNULL(E.Usd, 0)
          END AS Usd
         ,0 Credit
         ,CASE
            WHEN E.PayMissing = 1 THEN ISNULL(E.UsdPayMissing, 0)
            ELSE ISNULL(E.Usd, 0)
          END AS BalanceDetail

        FROM OtherPayments E
        INNER JOIN Agencies A
          ON A.AgencyId = E.AgencyId
        INNER JOIN dbo.Users U
          ON U.UserId = E.CreatedBy
        WHERE E.AgencyId = @AgencyId
        AND (CAST(E.CreationDate AS Date) >= CAST(@FromDate AS Date)
        OR @FromDate IS NULL)
        AND (CAST(E.CreationDate AS Date) <= CAST(@ToDate AS Date)
        OR @ToDate IS NULL)) AS Query) AS QueryFinal;


  RETURN;
END;





GO