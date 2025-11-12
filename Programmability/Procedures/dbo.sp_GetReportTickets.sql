SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:24-10-2023
--CAMBIOS EN 5463, cambiar fecha de  pago de comisiones

--LASTUPDATEDBY: fELIPE
--LASTUPDATEDON: 03-03-2024
--CAMBIOS EN 5667, Agregar balance inicial a los reportes Tickets y tickets details

CREATE PROCEDURE [dbo].[sp_GetReportTickets]
(@AgencyId INT, 
 @FromDate DATETIME = NULL, 
 @ToDate   DATETIME = NULL, 
 @Date     DATETIME
)
AS
    BEGIN
        DECLARE 

        @ProviderId AS INT,
        @FromDateInitial AS DATETIME;
        IF(@FromDate IS NULL)
            BEGIN
                SET @FromDate = DATEADD(day, -10, @Date);
                SET @ToDate = @Date;
            END;
        SET @FromDateInitial = DATEADD(day, -1, @FromDate);

        SET @ProviderId =
        (
            SELECT TOP 1 ProviderId
            FROM Providers
                 INNER JOIN ProviderTypes ON Providers.ProviderTypeId = ProviderTypes.ProviderTypeId
            WHERE ProviderTypes.Code = 'C24'
        );


      IF OBJECT_ID('#TempTable2') IS NOT NULL
            BEGIN
                DROP TABLE #TempTable2;
            END;

        CREATE TABLE #TempTable2
        (
         RowNumber       INT, 
         RowNumberDetail INT,
         Date            DATETIME, 
         Agency          VARCHAR(1000), 
         Description     VARCHAR(1000), 
         Details         VARCHAR(1000), 
         Type            VARCHAR(1000), 
         Transactions    INT, 
         USD             DECIMAL(18, 2), 
         Fee1            DECIMAL(18, 2), 
         Fee2            DECIMAL(18, 2), 
         FeeServices     DECIMAL(18, 2), 
         MoneyOrderFee   DECIMAL(18, 2), 
         Pago            DECIMAL(18, 2), 
         SumDetail       DECIMAL(18, 2), 
         Balance         DECIMAL(18, 2)
        );

        IF OBJECT_ID('#TempTable') IS NOT NULL
            BEGIN
                DROP TABLE #TempTable;
            END;
        CREATE TABLE #TempTable
        (
         RowNumberDetail     INT, 
         Date          DATETIME, 
         Agency        VARCHAR(1000), 
         Description   VARCHAR(1000), 
         Details       VARCHAR(1000), 
         Type          VARCHAR(1000), 
         Transactions  INT, 
         USD           DECIMAL(18, 2), 
         Fee1          DECIMAL(18, 2), 
         Fee2          DECIMAL(18, 2), 
         FeeServices   DECIMAL(18, 2), 
         MoneyOrderFee DECIMAL(18, 2), 
         Pago          DECIMAL(18, 2), 
         SumDetail     DECIMAL(18, 2),
         Balance       DECIMAL(18, 2)
        );
        INSERT INTO #TempTable
        (
         RowNumberDetail, 
         Date, 
         Agency, 
         Description, 
         Details, 
         Type, 
         Transactions,
		     USD, 
         Fee1, 
         Fee2, 
         FeeServices, 
         MoneyOrderFee, 
         Pago, 
         SumDetail,
         Balance
        )


  SELECT 
      *
    FROM (
        SELECT TOP 1
        RowNumberDetail
       ,CAST(@FromDateInitial AS Date) Date
       ,Agency      
--      ,CAST(Usd AS VARCHAR(100))
       ,'INITIAL BALANCE'  Description      
       ,'INITIAL BALANCE' Details
       ,0 Type
       ,0 Transactions 
       ,0 USD
       ,0 Fee1 
       ,0 Fee2 
       ,0 FeeServices 
       ,0 MoneyOrderFee
       ,0 Pago 
       ,Balance SumDetail
       ,Balance Balance 

      FROM dbo.[FN_GenerateBalanceTickets](NULL,@FromDateInitial,@AgencyId)
      ORDER BY RowNumberDetail DESC
      UNION ALL

      SELECT
        *
       FROM dbo.[FN_GenerateBalanceTickets](@FromDate,@ToDate,@AgencyId)
      WHERE Details != 'INITIAL BALANCE') AS Query;

  INSERT INTO #TempTable2 
  (
     RowNumber,
     RowNumberDetail, 
     Date, 
     Agency, 
     Description, 
     Details, 
     Type, 
     Transactions, 
     USD, 
     Fee1, 
     Fee2, 
     FeeServices, 
     MoneyOrderFee, 
     Pago, 
     SumDetail, 
     Balance
  )

    SELECT
      *
    FROM (SELECT
        ROW_NUMBER() OVER (ORDER BY CAST(Query.Date AS DATE) ASC, Query.Type ASC
        ) RowNumber
       ,*
      FROM (SELECT
          *
        FROM #TempTable) AS Query) AS QueryFinal;


  SELECT
    *
   ,(SELECT
        SUM(t2.SumDetail)
      FROM #TempTable2 t2
      WHERE t2.RowNumber <= t1.RowNumber)
    BalanceFinal
  FROM #TempTable2 t1
  ORDER BY RowNumber ASC;
END;






GO