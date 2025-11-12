SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:22-09-2023
--CAMBIOS EN 5398, Registros del modulo Concilliation deben hacer la operacion inversa en reportes


--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:09-10-2023
--CAMBIOS EN 5425 (NO DEBE DE MOSTRAR EL VALOR CONTABLE INVERSO SOLO PARA ESTE REPORTE)

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:11-10-2023
--CAMBIOS EN 5424, Refactoring reporte de sales tax 
CREATE PROCEDURE [dbo].[sp_GetReportSalesTax] (@AgencyId INT,
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

  DECLARE @initialBalanceFinalDate DATETIME
  SET @initialBalanceFinalDate = DATEADD(DAY, -1, @FromDate)
 
  CREATE TABLE #Temp (
    [ID] INT IDENTITY (1, 1)
   ,[Index] INT
   ,Date DATETIME
   ,Description VARCHAR(1000)
   ,Type VARCHAR(1000)
   ,TypeId INT
   ,Usd DECIMAL(18, 2)
   ,Debit DECIMAL(18, 2)
   ,Credit DECIMAL(18, 2)
   ,BalanceDetail DECIMAL(18, 2)

  )

  DECLARE @BalanceDetail DECIMAL(18, 2)
  SET @BalanceDetail = (SELECT
      SUM(ISNULL(BalanceDetail,0))
    FROM dbo.FN_GenerateSalesTaxReport(@AgencyId, '1985-01-01', @initialBalanceFinalDate))


  INSERT INTO #Temp
    SELECT
      0 [Index]
     ,CAST(@initialBalanceFinalDate AS Date) Date
     ,'INITIAL BALANCE' Description
     ,'INITIAL BALANCE' Type
     ,1 TypeId
     ,0 Usd
     ,0 Debit
     ,0 Credit
     ,ISNULL(@BalanceDetail,0) BalanceDetail

    UNION ALL

    SELECT
      *
    FROM [dbo].FN_GenerateSalesTaxReport(@AgencyId, @FromDate, @ToDate)
    ORDER BY Date,
    [Index];


  SELECT
    *
   ,(SELECT
        ISNULL(SUM(CAST(BalanceDetail AS DECIMAL(18, 2))), 0)
      FROM #Temp T2
      WHERE T2.ID <= T1.ID
      )
    BalanceFinal
   ,(SELECT
        SUM(ISNULL(t2.Usd, 0))
      FROM #Temp t2
      WHERE t2.ID <= T1.ID)
    SalesFinal
  FROM #Temp T1
  ORDER BY Date, T1.ID ASC;
  
  DROP TABLE #Temp
END
GO