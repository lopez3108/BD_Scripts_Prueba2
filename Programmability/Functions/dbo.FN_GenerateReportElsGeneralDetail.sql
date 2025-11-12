SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:21-09-2023
--CAMBIOS EN 5377,Refactorizacion de reporte ventra
CREATE   FUNCTION [dbo].[FN_GenerateReportElsGeneralDetail] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL)
RETURNS @result TABLE (
  [Index] INT
 ,AgencyId INT
 ,Date DATETIME
 ,Description VARCHAR(1000)
 ,Employee VARCHAR(1000)
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
      2
     ,S.AgencyId
     ,CAST(S.CreationDate AS DATE) AS DATE
     ,'CLOSING DAILY' Description
     ,u.Name AS Employee
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
    INNER JOIN Users u
      ON u.UserId = S.CreatedBy
    WHERE A.AgencyId = @AgencyId
    AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
    GROUP BY S.AgencyId
            ,A.Name
            ,u.Name
            ,CAST(S.CreationDate AS DATE)
            ,S.CityStickerId
  INSERT INTO @result
    SELECT
      3
     ,S.AgencyId
     ,CAST(S.CreationDate AS DATE) AS DATE
     ,'CLOSING DAILY' Description
     ,u.Name AS Employee
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
    INNER JOIN Users u
      ON u.UserId = S.CreatedBy
    WHERE A.AgencyId = @AgencyId
    AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
    GROUP BY S.AgencyId
            ,A.Name
            ,u.Name
            ,CAST(S.CreationDate AS DATE)
            ,S.CountryTaxId

  INSERT INTO @result
    SELECT
      4
     ,S.AgencyId
     ,CAST(S.CreationDate AS DATE) AS DATE
     ,'CLOSING DAILY' Description
     ,u.Name AS Employee
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
    INNER JOIN Users u
      ON u.UserId = S.CreatedBy
    WHERE A.AgencyId = @AgencyId
    AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
    GROUP BY S.AgencyId
            ,A.Name
            ,u.Name
            ,CAST(S.CreationDate AS DATE)
            ,S.ParkingTicketId
  INSERT INTO @result
    SELECT
      5
     ,S.AgencyId
     ,CAST(S.CreationDate AS DATE) AS DATE
     ,'CLOSING DAILY' Description
     ,u.Name AS Employee
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
    INNER JOIN Users u
      ON u.UserId = S.CreatedBy
    WHERE A.AgencyId = @AgencyId
    AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
    GROUP BY S.AgencyId
            ,A.Name
            ,u.Name
            ,CAST(S.CreationDate AS DATE)
            ,S.PlateStickerId
  INSERT INTO @result
    SELECT
      6
     ,S.AgencyId
     ,CAST(S.CreationDate AS DATE) AS DATE
     ,'CLOSING DAILY' Description
     ,u.Name AS Employee
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
    INNER JOIN Users u
      ON u.UserId = S.CreatedBy
    WHERE S.ProcessAuto = 1
    AND A.AgencyId = @AgencyId
    AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
    GROUP BY S.AgencyId
            ,A.Name
            ,u.Name
            ,CAST(S.CreationDate AS DATE)
            ,S.TitleId
  INSERT INTO @result
    SELECT
      7
     ,S.AgencyId
     ,CAST(S.CreationDate AS DATE) AS DATE
     ,'CLOSING DAILY' Description
     ,u.Name AS Employee
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
    INNER JOIN Users u
      ON u.UserId = S.CreatedBy
    WHERE A.AgencyId = @AgencyId
    AND (CAST(S.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
    OR @FromDate IS NULL)
    AND (CAST(S.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
    OR @ToDate IS NULL)
    GROUP BY S.AgencyId
            ,A.Name
            ,u.Name
            ,CAST(S.CreationDate AS DATE)
            ,S.TitleInquiryId


  RETURN;
END;
GO