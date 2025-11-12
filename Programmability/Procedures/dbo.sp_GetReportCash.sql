SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:19-09-2023
--CAMBIOS EN 5366, cambios en consultas de cash payment y other payment.

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:19-09-2023
--CAMBIOS EN 5424, Redondeo en el balance
-- =============================================
-- Author:      JF
-- Create date: 11/09/2024 6:21 p. m.
-- Database:    developing
-- Description: task 6054 Ajuste Bill labor pago con money order
-- =============================================


CREATE PROCEDURE [dbo].[sp_GetReportCash] (
@AgencyId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@Date DATETIME,
@Type INT = NULL)
AS
BEGIN

  IF (@FromDate IS NULL)
  BEGIN
    SET @FromDate = DATEADD(DAY, -10, @Date);
    SET @ToDate = @Date;
  END;



DECLARE @initialBalanceFinalDate DATETIME
SET @initialBalanceFinalDate = DATEADD(day, -1, @FromDate)

DECLARE @agencyInitialBalance DECIMAL(18,2)
--original
SET @agencyInitialBalance = ISNULL((SELECT SUM(CAST(Balance AS DECIMAL(18,2))) FROM dbo.FN_GenerateCashReport(@AgencyId, '1985-01-01', @initialBalanceFinalDate, @Type)),0)



  CREATE TABLE #Temp (
    [ID] INT IDENTITY(1,1)
    ,[Index] INT
   ,[Type] VARCHAR(50)
   ,CreationDate DATETIME
   ,[Description] VARCHAR(100)
   ,Credit DECIMAL(18, 2)
      ,Debit DECIMAL(18, 2)

   ,AccountNumberBank VARCHAR(60)
   ,Balance   DECIMAL(18, 2)
  );

  ---- Initial cash balance
  INSERT INTO #Temp
    SELECT
      0 [Index]
     ,'INITIAL BALANCE'
     ,CAST(@initialBalanceFinalDate AS DATE) as CreationDate
     ,'INITIAL BALANCE'
     ,0 AS Credit
     ,0 AS Debit
     ,NULL
	 ,@agencyInitialBalance
	  UNION ALL
        SELECT *
        FROM [dbo].[FN_GenerateCashReport](@AgencyId, @FromDate, @ToDate, @Type) 
        ORDER BY CreationDate, 
                 [Index]
  
  SELECT 
				 *,
				 (
            SELECT   ISNULL(SUM(CAST(Balance AS DECIMAL(18,2))), 0)
            FROM    #Temp T2
            WHERE T2.ID <= T1.ID
        ) RunningSum
				 FROM #Temp T1
      ORDER BY ID ASC
				 DROP TABLE #Temp

END;







GO