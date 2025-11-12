SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: Felipe
--LASTUPDATEDON:02-11-2023

CREATE FUNCTION [dbo].[FN_GetReportOtherPayment]
(
                 @AgencyId int, @FromDate datetime = NULL, @ToDate datetime = NULL
)
RETURNS @result TABLE
(
              RowNumber int,
              AgencyId int,
              Date datetime,
              Description varchar(1000),
              Type varchar(1000),
              TypeId int,
              Usd decimal(18, 2),
              Credit decimal(18, 2),
              BalanceDetail decimal(18, 2)
)


AS
BEGIN

  INSERT INTO @result

                  SELECT *
           FROM (SELECT ROW_NUMBER() OVER (ORDER BY Query.TypeId ASC, CAST(Query.Date AS date) ASC) RowNumber, *
         FROM (SELECT O.AgencyId, CAST(O.CreationDate AS date) AS DATE, 'OTHERS PAYMENTS' Description, 'CLOSING DAILY' Type, 1 TypeId, SUM(ISNULL(O.Usd, 0) + ISNULL(O.UsdPayMissing, 0)) AS Usd, 0 Credit, SUM(ISNULL(O.Usd, 0) + ISNULL(O.UsdPayMissing, 0)) AS BalanceDetail
       FROM OtherPayments O
            INNER JOIN
            Agencies A
            ON A.AgencyId = O.AgencyId
       WHERE A.AgencyId = @AgencyId AND
             CAST(O.CreationDate AS date) >= CAST(@FromDate AS date) AND
             CAST(O.CreationDate AS date) <= CAST(@ToDate AS date)
       GROUP BY O.AgencyId, CAST(O.CreationDate AS date)) AS Query) AS QueryFinal;


  RETURN;
END;




GO