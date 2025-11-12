SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--2024-04-20 JF/5801: 2- Ajustes reporte manager validated

--Last modification by:sergio
--change:add order by
--Date:03/05/2024 

CREATE PROCEDURE [dbo].[sp_GetReportManagerValidated] (@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@Date DATETIME)
AS
BEGIN
  IF (@FromDate IS NULL)
  BEGIN
    SET @FromDate = DATEADD(DAY, -10, @Date);
    SET @ToDate = @Date;
  END;

  /*Se comenta por que esta secion fué elimininada */
  --SELECT H.HeadphonesAndChargerId, 
  --       H.CreationDate, 
  --       'HEADPHONES AND CHANGERS' AS Type, 
  --       H.Usd, 
  --       SUBSTRING(u.Name, 1, 18) CreatedBy, 
  --       SUBSTRING(uv.Name, 1, 18) ValidatedBy, 
  --       SUBSTRING(H.Note, 1, 40) AS Note
  --FROM [dbo].HeadphonesAndChargersNotes H
  --     INNER JOIN Users u ON u.UserId = H.CreatedBy
  --     INNER JOIN Users uv ON uv.UserId = H.ValidatedBy
  --WHERE CAST(H.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
  --      AND CAST(H.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
  --      AND H.AgencyId = @AgencyId
  --      AND H.ValidatedBy IS NOT NULL
  --GROUP BY H.HeadphonesAndChargerId, 
  --         H.CreationDate, 
  --         H.Usd, 
  --         u.Name, 
  --         uV.Name, 
  --         H.Note
  --UNION
  SELECT query.PhoneCardId
   ,query.CreationDate
   ,query.Type
   ,query.Concept
   ,query.Usd
   ,query.CreatedBy
   ,query.ValidatedBy
   ,query.Note FROM (
  SELECT
    H.PhoneCardId
   ,H.CreationDate
   ,'PHONECARDS' AS Type
   ,'-' AS Concept
   ,H.Usd
   ,u.Name CreatedBy
   ,uv.Name ValidatedBy
   ,H.Note AS Note
  FROM [dbo].PhoneCardsNotes H
  INNER JOIN Users u
    ON u.UserId = H.CreatedBy
  INNER JOIN Users uv
    ON uv.UserId = H.ValidatedBy
  WHERE CAST(H.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
  AND CAST(H.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
  AND H.AgencyId = @AgencyId
  AND H.ValidatedBy IS NOT NULL
  GROUP BY H.PhoneCardId
          ,H.CreationDate
          ,H.Usd
          ,u.Name
          ,uv.Name
          ,H.Note


  UNION
  SELECT
    C.CancellationId
   ,C.CancellationDate
   ,'CANCELLATIONS' AS Type
   ,'-' AS Concept
   ,C.TotalTransaction
   ,u.Name CreatedBy
   ,uv.Name ValidatedBy
   ,'-' AS Note

  FROM [dbo].Cancellations C
  INNER JOIN Users u
    ON u.UserId = C.CreatedBy
  INNER JOIN Users uv
    ON uv.UserId = C.ValidatedBy
  WHERE CAST(C.CancellationDate AS DATE) >= CAST(@FromDate AS DATE)
  AND CAST(C.CancellationDate AS DATE) <= CAST(@ToDate AS DATE)
  AND C.AgencyId = @AgencyId
  AND C.ValidatedBy IS NOT NULL
  GROUP BY C.CancellationId
          ,C.CancellationDate
          ,C.TotalTransaction
          ,u.Name
          ,uv.Name


  UNION
  SELECT
    CE.CheckElsId
   ,CE.CreationDate
   ,'CHECKS' AS Type
   ,'-' AS Concept
   ,CE.Amount
   ,u.Name CreatedBy
   ,uv.Name ValidatedBy
   ,'-' AS Note

  FROM [dbo].ChecksEls CE
  INNER JOIN Users u
    ON u.UserId = CE.CreatedBy
  INNER JOIN Users uv
    ON uv.UserId = CE.ValidatedRoutingBy
  WHERE CAST(CE.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
  AND CAST(CE.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
  AND CE.AgencyId = @AgencyId
  AND CE.ValidatedRoutingBy IS NOT NULL
  GROUP BY CE.CheckElsId
          ,CE.CreationDate
          ,CE.Amount
          ,u.Name
          ,uv.Name

  UNION
  SELECT
    T.TitleId
   ,T.CreationDate
   ,'TITLE' AS Type
   ,'-' AS Concept
   ,T.USD + T.Fee1
   ,u.Name CreatedBy
   ,uv.Name ValidatedBy
   ,'-' AS Note

  FROM [dbo].Titles T
  INNER JOIN Users u
    ON u.UserId = T.CreatedBy
  INNER JOIN Users uv
    ON uv.UserId = T.ValidatedBy
  WHERE CAST(T.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
  AND CAST(T.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
  AND T.AgencyId = @AgencyId
  AND T.ValidatedBy IS NOT NULL
  GROUP BY T.TitleId
          ,T.CreationDate
          ,T.USD
          ,T.Fee1
          ,u.Name
          ,uv.Name

  UNION
  SELECT
    H.OtherDetailId
   ,H.CreationDate
   ,'OTHERS SERVICES' AS Type
   ,os.Name AS Concept
   ,H.Usd
   ,u.Name CreatedBy
   ,uv.Name ValidatedBy
   ,H.Note AS Note
  FROM [dbo].OthersNotes H
  INNER JOIN OthersDetails od
    ON H.OtherDetailId = od.OtherDetailId
  INNER JOIN OthersServices os
    ON od.OtherServiceId = os.OtherId
  INNER JOIN Users u
    ON u.UserId = H.CreatedBy
  INNER JOIN Users uv
    ON uv.UserId = H.ValidatedBy
  WHERE CAST(H.CreationDate AS DATE) >= CAST(@FromDate AS DATE)
  AND CAST(H.CreationDate AS DATE) <= CAST(@ToDate AS DATE)
  AND H.AgencyId = @AgencyId
  AND H.ValidatedBy IS NOT NULL
  GROUP BY H.OtherDetailId
          ,H.CreationDate
          ,H.Usd
          ,u.Name
          ,uv.Name
          ,H.Note
          ,os.Name) AS query 
  ORDER BY query.CreationDate ASC;-- se crea un order para el reporte manager validated
END;



GO