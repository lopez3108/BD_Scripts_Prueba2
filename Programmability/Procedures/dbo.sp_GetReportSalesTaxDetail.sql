SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:22-09-2023
--CAMBIOS EN 5398, Registros del modulo Concilliation deben hacer la operacion inversa en reportes

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:09-10-2023
--CAMBIOS EN 5425 (NO DEBE DE MOSTRAR EL VALOR CONTABLE INVERSO SOLO PARA ESTE REPORTE)
CREATE PROCEDURE [dbo].[sp_GetReportSalesTaxDetail]
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

  DECLARE @initialBalanceFinalDate DATETIME
  SET @initialBalanceFinalDate = DATEADD(DAY, -1, @FromDate)
  DECLARE @BalanceDetail DECIMAL(18, 2)
  SET @BalanceDetail = (SELECT SUM(CAST(BalanceDetail AS DECIMAL(18, 2))) FROM dbo.FN_GenerateSalesTaxDetailReport(@AgencyId, '1985-01-01', @initialBalanceFinalDate))


  CREATE TABLE #Temp (
    [ID] INT IDENTITY (1, 1)
   ,[Index] INT,
    Date          DATETIME, 
         Description   VARCHAR(1000), 
         Type          VARCHAR(1000), 
         Employee      VARCHAR(1000), 
         TypeId        INT, 
         Usd           DECIMAL(18, 2), 
         Debit         DECIMAL(18, 2), 
         Credit        DECIMAL(18, 2), 
         BalanceDetail DECIMAL(18, 2)

  )


  INSERT INTO #Temp
    SELECT
      0 [Index]
        ,CAST(@initialBalanceFinalDate AS Date) Date

     ,'INITIAL BALANCE' Description
     ,'INITIAL BALANCE' Type,
      'INITIAL BALANCE' Employee
     ,1 TypeId
     ,0 Usd
     ,0 Debit
     ,0 Credit
     ,@BalanceDetail BalanceDetail

    UNION ALL

    SELECT
      *
    FROM [dbo].FN_GenerateSalesTaxDetailReport(@AgencyId, @FromDate, @ToDate)
    ORDER BY Date,
    [Index];

  SELECT
    *
   ,(SELECT
        ISNULL(SUM(CAST(BalanceDetail AS DECIMAL(18, 2))), 0)
      FROM #Temp T2
      WHERE T2.ID <= T1.ID     AND (T2.BalanceDetail > 0
      OR T2.BalanceDetail < 0))
    BalanceFinal
  FROM #Temp T1
     ORDER BY T1.Date, T1.ID ASC;
  DROP TABLE #Temp
END


GO