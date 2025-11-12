SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:      JF
-- Create date: 23/06/2024 7:29 p. m.
-- Database:    devtest
-- Description: task: 5896  Ajustes reporte OTHER SERVICES
-- =============================================

-- =============================================
-- Author:      JF
-- Create date: 12/09/2024 1:23 p. m.
-- Database:    developing
-- Description: task 6051 Agregar un nuevo filtro al reporte others services 
-- =============================================


CREATE PROCEDURE [dbo].[sp_GetReportOthersDescription] 
      (
          @AgencyId INT,
          @FromDate DATETIME = NULL,
          @ToDate DATETIME = NULL,
          @Date DATETIME,
          @OthersIds VARCHAR(100) = NULL,
          @CashiersIds VARCHAR(100) = NULL
      )
AS

BEGIN
  IF (@FromDate IS NULL)
  BEGIN
    SET @FromDate = DATEADD(DAY, -10, @Date);
    SET @ToDate = @Date;
  END;
  DECLARE @initialBalanceFinalDate DATETIME
  SET @initialBalanceFinalDate = DATEADD(DAY, -1, @FromDate)
--  DECLARE @BalanceDetail DECIMAL(18, 2)
--  SET @BalanceDetail = ISNULL((SELECT
--      SUM(CAST(Balance AS DECIMAL(18, 2)))
--    FROM [dbo].fn_GenerateOthersDescriptionReport(@AgencyId, @FromDate, @ToDate,@OthersIds))
--  , 0)


  CREATE TABLE #Temp (
    [ID] INT IDENTITY (1, 1)
   ,[Index] INT
   ,Date DATETIME
   ,Type VARCHAR(1000)
   ,Description VARCHAR(1000)
   ,Transactions INT
   ,NameEmployee VARCHAR(80)
   ,TypeId INT
   ,Usd DECIMAL(18, 2)
   ,Commission DECIMAL(18, 2)
   ,Balance DECIMAL(18, 2)
  );
  INSERT INTO #Temp



  -- Initial cash balance
--  INSERT INTO #Temp
--  	SELECT
--            0  [Index]
--            ,CAST(@initialBalanceFinalDate AS DATE) Date
--            ,'INITIAL BALANCE' Type
--            ,'INITIAL BALANCE' Description
--            ,0 AS Transactions
--            ,NULL
--            ,1 TypeId
--            ,0
--            ,0
--            ,0 Balance
--  --
--   UNION ALL


  SELECT
    *
  FROM [dbo].fn_GenerateOthersDescriptionReport(@AgencyId, @FromDate, @ToDate,@OthersIds,@CashiersIds)
  ORDER BY Date,
  [Index];


  SELECT
    *
   ,(SELECT
      ISNULL(SUM(CAST(Balance AS DECIMAL(18,2))), 0)
      FROM #Temp T2
      WHERE T2.ID <= T1.ID)
    BalanceFinal
  FROM #Temp T1

  ORDER BY Date,
  [Index];
  DROP TABLE #Temp;

END;







GO