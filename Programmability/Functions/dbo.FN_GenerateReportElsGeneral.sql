SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:20-09-2023
--CAMBIOS EN 5389,Refactorizacion de reporte vehicle service
CREATE   FUNCTION [dbo].[FN_GenerateReportElsGeneral] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL)
RETURNS @result TABLE (
  [Index] INT
 ,AgencyId INT
 ,Date DATETIME
 ,Description VARCHAR(1000)
 ,Type VARCHAR(1000)
 ,TypeId INT
 ,Transactions INT
 ,Usd DECIMAL(18, 2)
 ,FeeService DECIMAL(18, 2)
 ,FeeEls DECIMAL(18, 2)
 ,CommissionsEls DECIMAL(18, 2)
 ,BalanceDetail DECIMAL(18, 2)
)


AS
BEGIN
 


  INSERT INTO @result
    SELECT
    2,
      S.AgencyId
     ,CAST(S.CreationDate AS DATE) AS DATE
     ,'CLOSING DAILY' Description
     ,'CITY STICKER' Type
     ,1 TypeId
     ,COUNT(*) Transactions
     ,SUM(ISNULL(S.Usd, 0)) AS Usd
     ,SUM(ISNULL(S.Fee1, 0)) FeeService
     ,SUM(ISNULL(S.FeeEls, 0)) AS FeeEls
     ,SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS CommissionsEls
     ,SUM(ISNULL(S.Usd, 0)) + SUM(ISNULL(S.Fee1, 0)) AS BalanceDetail
    FROM CityStickers S
    INNER JOIN Agencies A
      ON A.AgencyId = S.AgencyId
    WHERE A.AgencyId = @AgencyId
    AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
    GROUP BY S.AgencyId
            ,A.Name
            ,CAST(S.CreationDate AS DATE)


  INSERT INTO @result
    SELECT
    3,
      S.AgencyId
     ,CAST(S.CreationDate AS DATE) AS DATE
     ,'CLOSING DAILY' Description
     ,'COUNTY TAX' Type
     ,2 TypeId
     ,COUNT(*) Transactions
     ,SUM(ISNULL(S.Usd, 0)) AS Usd
     ,SUM(ISNULL(S.Fee1, 0)) FeeService
     ,SUM(ISNULL(S.FeeEls, 0)) AS FeeEls
     ,SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS CommissionsEls
     ,SUM(ISNULL(S.Usd, 0)) + SUM(ISNULL(S.Fee1, 0)) AS BalanceDetail
    FROM CountryTaxes S
    INNER JOIN Agencies A
      ON A.AgencyId = S.AgencyId
    WHERE A.AgencyId = @AgencyId
    AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
    GROUP BY S.AgencyId
            ,A.Name
            ,CAST(S.CreationDate AS DATE)


  --UNION ALL // no va pero se deja como evidencia, se encontro asi.
  --SELECT S.AgencyId,
  --       CAST(S.CreationDate AS DATE) AS DATE,
  --       'CLOSING DAILY' Description,
  --       'PARKING TICKET CARD' Type,
  --       3 TypeId,
  --       COUNT(*) Transactions,
  --       SUM(ISNULL(S.USD, 0)) + SUM(ISNULL(S.Fee1, 0)) AS Debit, --Usd + feeState(fee1)
  --       0 AS Credit,
  --       SUM(ISNULL(S.USD, 0)) + SUM(ISNULL(S.Fee1, 0)) AS BalanceDetail
  --FROM ParkingTicketsCards S
  --     INNER JOIN Agencies A ON A.AgencyId = S.AgencyId
  --WHERE A.AgencyId = @AgencyId
  --      AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
  --           OR @FromDate IS NULL)
  --      AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
  --           OR @ToDate IS NULL)
  --GROUP BY S.AgencyId,
  --         A.Name,
  --         CAST(S.CreationDate AS DATE)


  INSERT INTO @result
    SELECT
    4,
      S.AgencyId
     ,CAST(S.CreationDate AS DATE) AS DATE
     ,'CLOSING DAILY' Description
     ,'PARKING TICKET ELS' Type
     ,4 TypeId
     ,COUNT(*) Transactions
     ,SUM(ISNULL(S.Usd, 0)) AS Usd
     ,SUM(ISNULL(S.Fee1, 0)) FeeService
     ,SUM(ISNULL(S.FeeEls, 0)) AS FeeEls
     ,SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS CommissionsEls
     ,SUM(ISNULL(S.Usd, 0)) + SUM(ISNULL(S.Fee1, 0)) AS BalanceDetail
    FROM ParkingTickets S
    INNER JOIN Agencies A
      ON A.AgencyId = S.AgencyId
    WHERE A.AgencyId = @AgencyId
    AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
    GROUP BY S.AgencyId
            ,A.Name
            ,CAST(S.CreationDate AS DATE)


  INSERT INTO @result
    SELECT
    5,
      S.AgencyId
     ,CAST(S.CreationDate AS DATE) AS DATE
     ,'CLOSING DAILY' Description
     ,'REGISTRATION RENEWALS' Type
     ,5 TypeId
     ,COUNT(*) Transactions
     ,SUM(ISNULL(S.Usd, 0)) AS Usd
     ,SUM(ISNULL(S.Fee1, 0)) FeeService
     ,SUM(ISNULL(S.FeeEls, 0)) AS FeeEls
     ,SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS CommissionsEls
     ,SUM(ISNULL(S.Usd, 0)) + SUM(ISNULL(S.Fee1, 0)) AS BalanceDetail
    FROM PlateStickers S
    INNER JOIN Agencies A
      ON A.AgencyId = S.AgencyId
    WHERE A.AgencyId = @AgencyId
    AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
    GROUP BY S.AgencyId
            ,A.Name
            ,CAST(S.CreationDate AS DATE)


  INSERT INTO @result
    SELECT
    6,
      S.AgencyId
     ,CAST(S.CreationDate AS DATE) AS DATE
     ,'CLOSING DAILY' Description
     ,'TITLE AND PLATES' Type
     ,7 TypeId
     ,COUNT(*) Transactions
     ,SUM(ISNULL(S.Usd, 0)) AS Usd
     ,SUM(ISNULL(S.Fee1, 0)) FeeService
     ,SUM(ISNULL(S.FeeEls, 0)) AS FeeEls
     ,SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS CommissionsEls
     ,SUM(ISNULL(S.Usd, 0)) + SUM(ISNULL(S.Fee1, 0)) AS BalanceDetail
    FROM Titles S
    INNER JOIN Agencies A
      ON A.AgencyId = S.AgencyId
    WHERE S.ProcessAuto = 1
    AND A.AgencyId = @AgencyId
    AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
    GROUP BY S.AgencyId
            ,A.Name
            ,CAST(S.CreationDate AS DATE)


  INSERT INTO @result
    SELECT
    7,
      S.AgencyId
     ,CAST(S.CreationDate AS DATE) AS DATE
     ,'CLOSING DAILY' Description
     ,'TITLE INQUIRY' Type
     ,8 TypeId
     ,COUNT(*) Transactions
     ,SUM(ISNULL(S.Usd, 0)) AS Usd
     ,SUM(ISNULL(S.Fee1, 0)) FeeService
     ,SUM(ISNULL(S.FeeEls, 0)) AS FeeEls
     ,SUM(ISNULL(S.Fee1, 0)) - SUM(ISNULL(S.FeeEls, 0)) AS CommissionsEls
     ,SUM(ISNULL(S.Usd, 0)) + SUM(ISNULL(S.Fee1, 0)) AS BalanceDetail
    FROM TitleInquiry S
    INNER JOIN Agencies A
      ON A.AgencyId = S.AgencyId
    WHERE A.AgencyId = @AgencyId
    AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
    GROUP BY S.AgencyId
            ,A.Name
            ,CAST(S.CreationDate AS DATE)



  RETURN;
END;
GO