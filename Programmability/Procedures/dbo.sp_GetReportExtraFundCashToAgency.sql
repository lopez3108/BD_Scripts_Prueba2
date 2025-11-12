SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetReportExtraFundCashToAgency]
(@AgencyId INT,
 @FromDate DATETIME = NULL,
 @ToDate   DATETIME = NULL,
 @Date     DATETIME
)
AS
BEGIN
 IF (@FromDate IS NULL)
  BEGIN
    SET @FromDate = DATEADD(DAY, -10, @Date);
    SET @ToDate = @Date;
  END;

 CREATE TABLE #Temp (
    [ID] INT IDENTITY (1, 1),
	[Index] INT,
	ExtraFundId INT,
          [Type]        VARCHAR(30),
          CreationDate  DATETIME,
          [Description] VARCHAR(100),
          Debit         DECIMAL(18, 2) NULL,
          Credit        DECIMAL(18, 2) NULL,
		  Usd DECIMAL(18, 2) NULL

  )
  
  INSERT INTO #Temp
  SELECT * FROM (
  SELECT 
  1 as [Index],
  e.ExtraFundAgencyToAgencyId as ExtraFundId,
  'CASH FROM AGENCY' as [Type],
  CAST(e.CreationDate as DATE) as [Date],
  'FROM ' + a.Code + ' TO ' + at.Code as [Description],
  0 as Debit,
  (e.Usd * -1) as Credit,
   (e.Usd) as Usd
  FROM dbo.ExtraFundAgencyToAgency e
  INNER JOIN dbo.Agencies a ON a.AgencyId = e.FromAgencyId
  INNER JOIN dbo.Agencies at ON at.AgencyId = e.ToAgencyId 
  WHERE e.FromAgencyId = @AgencyId
  AND (CAST(e.CreationDate as DATE) >= CAST(@FromDate as DATE) AND CAST(e.CreationDate as DATE) <= CAST(@ToDate as DATE)) 
  UNION ALL
  SELECT 
  2 as [Index],
  e.ExtraFundAgencyToAgencyId as ExtraFundId,
  'CASH TO AGENCY' as [Type],
  CAST(e.CreationDate as DATE) as [Date],
  'TO ' + at.Code + ' FROM ' + a.Code as [Description],
  (e.Usd * -1) as Debit,
  0 as Credit,
 (e.Usd * -1) as Usd
  FROM dbo.ExtraFundAgencyToAgency e
  INNER JOIN dbo.Agencies a ON a.AgencyId = e.FromAgencyId
  INNER JOIN dbo.Agencies at ON at.AgencyId = e.ToAgencyId 
  WHERE e.AcceptedBy IS NOT NULL
  AND e.FromAgencyId = @AgencyId
  AND (CAST(e.CreationDate as DATE) >= CAST(@FromDate as DATE) AND CAST(e.CreationDate as DATE) <= CAST(@ToDate as DATE)) ) q
  ORDER BY q.Date ASC, q.ExtraFundId, q.[Index]

  SELECT *,
   SUM(t.Usd) OVER(ORDER BY t.ID 
     ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 
          AS Balance
		  FROM  #Temp t

  DROP TABLE #Temp

END

GO