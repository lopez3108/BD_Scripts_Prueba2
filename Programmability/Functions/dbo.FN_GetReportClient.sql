SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: Felipe
--LASTUPDATEDON:26-10-2023

CREATE FUNCTION [dbo].[FN_GetReportClient]
(
                 @AgencyId int, @FromDate datetime = NULL, @ToDate datetime = NULL,@ClientId int = NULL, @Code varchar(3) = NULL
)
RETURNS @result TABLE
(
            RowNumber int,
              CreationDate datetime,
              DateCheck datetime,
              StoreId varchar(1000),
              ClienteId varchar(1000),
              Maker varchar(1000),
              Routing varchar(1000),
              Account varchar(1000),
              CheckNumber varchar(1000),
              BalanceDetail decimal(18, 2)
)


AS
BEGIN

  INSERT INTO @result
   SELECT *
         FROM (SELECT ROW_NUMBER() OVER (ORDER BY CAST(Query.CreationDate AS date) ASC) RowNumber, *
       FROM (SELECT ce1.CreationDate, ce1.CheckDate AS DateCheck, ag.code + ' - ' + ag.Name AS StoreId, ce.ClienteId AS ClienteId, M.Name AS Maker, c.Routing AS Routing, c.Account AS Account, ce1.CheckNumber AS CheckNumber, SUM(ce1.Amount) AS BalanceDetail
     FROM Clientes ce
          INNER JOIN
          Checks c
          ON c.ClientId = ce.ClienteId
          INNER JOIN
          dbo.ChecksEls ce1
          ON c.CheckId = ce1.CheckId
          INNER JOIN
          Agencies ag
          ON ag.AgencyId = c.AgencyId
          INNER JOIN
          Makers M
          ON M.MakerId = c.Maker
     WHERE (ce.ClienteId = @ClientId) AND

           (

           (@Code = 'C01' AND
           CAST(ce1.CreationDate AS date) >= CAST(@FromDate AS date) AND
           CAST(ce1.CreationDate AS date) <= CAST(@ToDate AS date)) OR
           (@Code = 'C02' AND
           CAST(ce1.CheckDate AS date) >= CAST(@FromDate AS date) AND
           CAST(ce1.CheckDate AS date) <= CAST(@ToDate AS date)))





     GROUP BY ce1.CheckNumber, M.Name, ag.Name, ce.ClienteId, ag.Code, ce1.CreationDate, ce1.CheckDate, c.DateCheck,
     --								c.DateCashed,
     c.Routing, c.Account) AS Query) AS QueryFinal;

  RETURN;
END;
GO