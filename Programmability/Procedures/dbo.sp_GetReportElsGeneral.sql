SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:20-09-2023
--CAMBIOS EN 5389,Refactorizacion de reporte vehicle service
CREATE PROCEDURE [dbo].[sp_GetReportElsGeneral]
(@AgencyId INT,
 @FromDate DATETIME = NULL,
 @ToDate   DATETIME = NULL,
 @Date     DATETIME
)
AS
BEGIN
 DECLARE @FromDateInitial AS DATETIME;
         IF(@FromDate IS NULL)
             BEGIN
                 SET @FromDate = DATEADD(day, -10, @Date);
                 SET @ToDate = @Date;
         END;



 CREATE TABLE #Temp
         (
           [ID] INT IDENTITY(1,1),
           [Index]        INT, 
          AgencyId        INT,
          Date            DATETIME,
          Description     VARCHAR(1000),
          Type            VARCHAR(1000),
          TypeId          INT,
          Transactions    INT,
          Usd             DECIMAL(18, 2),
          FeeService      DECIMAL(18, 2),
          FeeEls          DECIMAL(18, 2),
          CommissionsEls  DECIMAL(18, 2),
          BalanceDetail   DECIMAL(18, 2)
         );




  		INSERT INTO #Temp
--                 SELECT 1 [Index],
--                                 @AgencyId AgencyId,
--                                 CAST(@FromDateInitial AS DATE) Date,
--                                 'INITIAL BALANCE' Description,
--                                 'INITIAL BALANCE' Type,
--                                 0 TypeId,
--                                 0 Transactions,
--                                 0 Usd,
--                                 0 FeeService,
--                                 0 FeeEls,
--                                 0 CommissionsEls,
--                                 @BalanceDetail BalanceDetail
  			
--         UNION ALL

          SELECT *
          FROM [dbo].FN_GenerateReportElsGeneral(@AgencyId, @FromDate, @ToDate)
          ORDER BY Date, 
                   [Index];
  

	SELECT 
  				 *,
  				 (
              SELECT ISNULL( SUM(CAST(BalanceDetail AS DECIMAL(18,2))), 0)
              FROM    #Temp T2
              WHERE T2.ID <= T1.ID
          ) BalanceFinal
          	
  				 FROM #Temp T1
  
  				 DROP TABLE #Temp


END







GO