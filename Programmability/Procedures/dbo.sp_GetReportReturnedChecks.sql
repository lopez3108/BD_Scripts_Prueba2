SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetReportReturnedChecks]
(
                 @AgencyId int, @FromDate datetime = NULL, @ToDate datetime = NULL, @Date datetime, @CodeFilter varchar(3) = NULL
)
AS
BEGIN

  IF (@FromDate IS NULL)
  BEGIN
    SET @FromDate = DATEADD(DAY, -10, @Date);
    SET @ToDate = @Date;
  END;

  DECLARE @FromDateFinalDate AS date;
  SET @FromDateFinalDate = DATEADD(DAY, -1, @FromDate);
  DECLARE @Usd decimal(18, 2)
  SET @Usd = ISNULL((SELECT SUM(CAST(BalanceUsd AS decimal(18, 2)))
FROM dbo.FN_GenerateReturnedChecksReport(@AgencyId, '1985-01-01', @FromDateFinalDate, @CodeFilter)), 0)


  CREATE TABLE #Temp
  (
              [ID] int IDENTITY (1, 1)
              , [Index] int
              , [Type] varchar(30)
              , [CreationDate] datetime
              , [Provider] varchar(30)
              , [Number] varchar(50)
              , [Reason] varchar(50)
              , [Client] varchar(50)
              , [Usd] decimal(18, 2) NULL
              , [ProviderFee] decimal(18, 2) NULL
              , [LauyeUsd] decimal(18, 2) NULL
              , [CourtUsd] decimal(18, 2) NULL
              , [Status] varchar(50)
              , [Debit] decimal(18, 2) NULL
              , [Credit] decimal(18, 2) NULL
              , [BalanceUsd] decimal(18, 2) NULL
  );

  INSERT INTO #Temp
         SELECT 0 [Index]
         , 'INITIAL BALANCE'
         , CAST(@FromDateFinalDate AS date) CreationDate
         , '-'
         , '-'
         , '-'
         , '-'
         , 0
         , 0 AS ProviderFee
         , 0 AS LauyeUsd
         , 0 AS CourtUsd
         , '-' AS Status
         , 0 AS Debit
         , 0 AS Credit
         , ISNULL(@Usd, 0) BalanceUsd

         UNION ALL

         SELECT *
         FROM dbo.FN_GenerateReturnedChecksReport(@AgencyId, @FromDate, @ToDate, @CodeFilter)
          ORDER BY CreationDate,
    [Index]



  SELECT *
  , (SELECT ISNULL(SUM(CAST(BalanceUsd AS decimal(18, 2))), 0)
FROM #Temp T2
WHERE T2.ID <= T1.ID) BalanceFinal
  FROM #Temp T1


  DROP TABLE #Temp


END;








GO