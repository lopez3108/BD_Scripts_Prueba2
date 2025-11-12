SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:22-09-2023
--CAMBIOS EN 5398, Registros del modulo Concilliation deben hacer la operacion inversa en reportes

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:09-10-2023
--CAMBIOS EN 5425 (NO DEBE DE MOSTRAR EL VALOR CONTABLE INVERSO SOLO PARA ESTE REPORTE)
CREATE PROCEDURE [dbo].[sp_GetReportExpenseBankDetail]
(@AgencyId INT, 
 @FromDate DATETIME = NULL, 
 @ToDate   DATETIME = NULL, 
 @Date     DATETIME
)
AS
    BEGIN



	  IF(@FromDate IS NULL)
            BEGIN
                SET @FromDate = DATEADD(day, -10, @Date);
                SET @ToDate = @Date;
            END;
      
	  IF OBJECT_ID('#TempTableExpenseDetail') IS NOT NULL
            BEGIN
                DROP TABLE #TempTableExpenseDetail;
            END;

			CREATE TABLE #TempTableExpenseDetail
        ([ID] INT IDENTITY (1, 1), 
         Date          DATETIME, 
         Type          VARCHAR(1000), 
         Description   VARCHAR(1000), 
         Account       VARCHAR(15), 
         Employee      VARCHAR(50), 
         TypeId        INT, 
         Debit         DECIMAL(18, 2), 
         Credit        DECIMAL(18, 2), 
         BalanceDetail DECIMAL(18, 2)
        );

		DECLARE @initialBalanceFinalDate DATETIME
  SET @initialBalanceFinalDate = DATEADD(DAY, -1, @FromDate)

  DECLARE @initialBalance DECIMAL(18,2)
  SET @initialBalance = ISNULL((SELECT SUM(BalanceDetail) FROM dbo.fn_GetReportExpenseBankDetail(@AgencyId, '1985-01-01', @initialBalanceFinalDate, @Date) qi),0)

  INSERT INTO #TempTableExpenseDetail
SELECT 
@initialBalanceFinalDate,
'INITIAL BALANCE',
'INITIAL BALANCE',
'-',
'-',
1,
CASE WHEN @initialBalance >= 0 THEN ABS(@initialBalance) ELSE 0 END,
CASE WHEN @initialBalance < 0 THEN ABS(@initialBalance) ELSE 0 END,
@initialBalance
UNION ALL       
SELECT 
q.Date,
q.Type,
q.Description,
q.Account,
q.Employee,
q.TypeId,
q.Debit,
q.Credit,
q.BalanceDetail
FROM dbo.fn_GetReportExpenseBankDetail(@AgencyId, @FromDate, @ToDate, @Date) q

SELECT *, 
(SELECT
       ISNULL( SUM(CAST(BalanceDetail AS DECIMAL(18,2))),0)
      FROM #TempTableExpenseDetail T2
      WHERE T2.ID <= T1.ID)
    RunningSum FROM #TempTableExpenseDetail T1

DROP TABLE #TempTableExpenseDetail

   
    END;

GO