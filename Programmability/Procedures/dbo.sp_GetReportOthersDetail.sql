SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:13-10-2023
--CAMBIOS EN 5424, Refactoring reporte de others detail

-- =============================================
-- Author:      sa
-- Create date: 23/06/2024 11:32 p. m.
-- Database:    devtest
-- Description: task: 5896  Ajustes reporte OTHER SERVICES
-- =============================================


CREATE         PROCEDURE [dbo].[sp_GetReportOthersDetail]
(@AgencyId INT, 
 @FromDate DATETIME = NULL, 
 @ToDate   DATETIME = NULL, 
 @Date     DATETIME
-- @OthersIds VARCHAR(100) = NULL
)
AS

     BEGIN
         IF(@FromDate IS NULL)
             BEGIN
SET @FromDate = DATEADD(DAY, -10, @Date);
SET @ToDate = @Date;
         END;
       DECLARE @initialBalanceFinalDate DATETIME
SET @initialBalanceFinalDate = DATEADD(day, -1, @FromDate)
 DECLARE @BalanceDetail DECIMAL(18, 2)
  SET @BalanceDetail = ISNULL((SELECT
      SUM(CAST(Balance AS DECIMAL(18,2)))
    FROM [dbo].fn_GenerateOthersDetailsDetailReport(@AgencyId, '1985-01-01', @initialBalanceFinalDate))
  , 0)


CREATE TABLE #Temp (
          [ID] INT IDENTITY (1, 1),
          [Index] INT,
          Date          DATETIME, 
          Type          VARCHAR(1000), 
          Description   VARCHAR(1000),
          Transactions  INT,
          NameEmployee  VARCHAR(80),
          TypeId        INT, 
          Usd           DECIMAL(18, 2), 
          Commission    DECIMAL(18, 2), 
          Balance DECIMAL(18,2)  
); 


-- Initial cash balance
INSERT INTO #Temp
	SELECT
          0  [Index]
          ,CAST(@initialBalanceFinalDate AS DATE) Date
          ,'INITIAL BALANCE' Type
          ,'INITIAL BALANCE' Description
          ,'-' Transactions
          ,NULL
          ,1 TypeId
          ,0
          ,0
          ,@BalanceDetail Balance

 UNION ALL
    SELECT
      *
    FROM [dbo].fn_GenerateOthersDetailsDetailReport(@AgencyId, @FromDate, @ToDate)
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