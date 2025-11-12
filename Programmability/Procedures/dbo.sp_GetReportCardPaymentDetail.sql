SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Nombre:  sp_GetReportCardPaymentDetail				    															         
-- Descripcion: Procedimiento Almacenado que consulta la lista de card payments details en un periodo y con su respectivo balance inicial		    					         
-- Creado por: 	John Terry García Martínez																						 
-- Fecha: 																								 	
-- Modificado por: John Terry García Martínez																							 
-- Fecha edición : 2023-09-20																											 
-- Observación:  Consulta los card payments details dentro de la función [FN_GenerateBalanceCardPaymentDetails] por  @AgencyId, @FromDate, @ToDate
-- Test: EXECUTE [dbo].sp_GetReportCardPayment @AgencyId = 1, @FromDate = NULL, @ToDate = NULL, @Date = GETDATE()
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[sp_GetReportCardPaymentDetail]
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
         SET @FromDateInitial = DATEADD(day, -1, @FromDate);

  IF OBJECT_ID('#TempTableCardPaymentDetailFinal') IS NOT NULL 
  BEGIN
    DROP TABLE #TempTableCardPaymentDetailFinal;
  END;
  CREATE TABLE #TempTableCardPaymentDetailFinal (
    RowNumber INT
   ,RowNumberDetail INT
   ,AgencyId INT
   ,Date DATETIME
   ,Description VARCHAR(1000)
   ,Type VARCHAR(1000)   
	 ,CreatedBy   VARCHAR(1000)
   ,Transactions INT
   ,TypeId INT
   ,Debit DECIMAL(18, 2)
   ,Credit DECIMAL(18, 2)
   ,BalanceDetail DECIMAL(18, 2)
   ,Balance DECIMAL(18, 2)
  );

        IF OBJECT_ID('#TempTableCardPaymentDetail') IS NOT NULL
            BEGIN
                DROP TABLE #TempTableCardPaymentDetail;
            END;
        CREATE TABLE #TempTableCardPaymentDetail
        (RowNumberDetail     INT, 
         AgencyId      INT, 
         Date          DATETIME, 
         Description   VARCHAR(1000), 		
         Type          VARCHAR(1000), 
		     CreatedBy   VARCHAR(1000), 
         Transactions  INT, 
         TypeId        INT, 
         Debit         DECIMAL(18, 2), 
         Credit        DECIMAL(18, 2), 
         BalanceDetail DECIMAL(18, 2),
         Balance DECIMAL(18, 2)
        );
        INSERT INTO #TempTableCardPaymentDetail
        (RowNumberDetail, 
         AgencyId, 
         Date, 
         Description, 
         Type, 
		      CreatedBy,
         Transactions, 
         TypeId, 
         Debit, 
         Credit, 
         BalanceDetail,
         Balance
        )
           SELECT 
      *
    FROM (SELECT TOP 1
        RowNumberDetail
       ,AgencyId
       ,CAST(@FromDateInitial AS Date) Date
       ,'INITIAL BALANCE' Description
       ,'INITIAL BALANCE' Type
       ,'' CreatedBy
       ,0 Transactions
       ,0 TypeId 
       ,0 Debit
       ,0 Credit
       ,Balance BalanceDetail
       ,Balance
      FROM dbo.[FN_GenerateBalanceCardPaymentDetail](@AgencyId, NULL, @FromDateInitial)
      ORDER BY RowNumberDetail DESC
      UNION ALL

      SELECT
        *
      FROM dbo.[FN_GenerateBalanceCardPaymentDetail](@AgencyId, @FromDate, @ToDate)
      WHERE Type != 'INITIAL BALANCE') AS Query;
  INSERT INTO #TempTableCardPaymentDetailFinal (RowNumber,
  RowNumberDetail,
  AgencyId,
  Date,
  Description,
  Type,
  CreatedBy,
  Transactions,
  TypeId,
  Debit,
  Credit,
  BalanceDetail,
  Balance)
    SELECT
      *
    FROM (SELECT
        ROW_NUMBER() OVER (ORDER BY CAST(Query.Date AS DATE) ASC, Query.TypeId ASC
        ) RowNumber
       ,*
      FROM (SELECT
          *
        FROM #TempTableCardPaymentDetail) AS Query) AS QueryFinal;
  SELECT
    *
   ,(SELECT
        SUM(t2.BalanceDetail)
      FROM #TempTableCardPaymentDetailFinal t2
      WHERE t2.RowNumber <= t1.RowNumber)
    BalanceFinal
  FROM #TempTableCardPaymentDetailFinal t1
  ORDER BY RowNumber ASC;
END;

GO