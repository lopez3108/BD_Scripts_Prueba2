SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:24-10-2023
--CAMBIOS EN 5463, cambiar fecha de  pago de comisiones

--LASTUPDATEDBY: fELIPE
--LASTUPDATEDON: 04-03-2024
--CAMBIOS EN 5667, Agregar balance inicial a los reportes Tickets y tickets details

-- LASTUPDATEDBY JT 
-- date: 17-marzo-2024
-- task 5732 Discriminar payments y poner debajo de su respectivo traffic ticket


-- LASTUPDATEDBY Sergio 
-- date: 12-abril-2024
-- task 5793 Agregar ticket number a los tipos traffic tickets y payments


  CREATE PROCEDURE [dbo].[sp_GetReportTicketsDetails]
  (
     @AgencyId int, 
     @FromDate datetime = NULL, 
     @ToDate datetime = NULL, 
     @Date datetime
  )
AS
BEGIN
   DECLARE 

        @ProviderId AS INT,
        @FromDateInitial AS DATETIME;

  IF (@FromDate IS NULL)
  BEGIN
    SET @FromDate = DATEADD(DAY, -10, @Date);
    SET @ToDate = @Date;
  END;
  SET @FromDateInitial = DATEADD(day, -1, @FromDate);


--  SET @ProviderId = (SELECT ProviderId
--  FROM Providers
--       INNER JOIN  ProviderTypes ON Providers.ProviderTypeId = ProviderTypes.ProviderTypeId
--  WHERE ProviderTypes.Code = 'C24');


        IF OBJECT_ID('#TempTable2') IS NOT NULL
        BEGIN
            DROP TABLE #TempTable2;
        END;
  
  
     CREATE TABLE #TempTable2
        (
           RowNumber       INT, 
           RowNumberDetail INT,
                      [Index] INT,

           Date            DATETIME, 
           Agency          VARCHAR(1000), 
           Description     VARCHAR(1000), 
           Name            VARCHAR(1000),
           Details         VARCHAR(1000), 
           Type            VARCHAR(1000), 
           TicketNumber    VARCHAR(40), 
           Transactions    INT, 
           USD             DECIMAL(18, 2), 
           Fee1            DECIMAL(18, 2), 
           Fee2            DECIMAL(18, 2), 
           FeeServices     DECIMAL(18, 2), 
           TicketId INT,
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
           [Index] INT,
           Date          DATETIME, 
           Agency        VARCHAR(1000), 
           Description   VARCHAR(1000), 
           Name          VARCHAR(1000),
           Details       VARCHAR(1000), 
           Type          VARCHAR(1000), 
            TicketNumber    VARCHAR(40), 

           Transactions  INT, 
           USD           DECIMAL(18, 2), 
           Fee1          DECIMAL(18, 2), 
           Fee2          DECIMAL(18, 2), 
           FeeServices   DECIMAL(18, 2), 
                    TicketId INT,
           MoneyOrderFee DECIMAL(18, 2), 
           Pago          DECIMAL(18, 2), 
           SumDetail     DECIMAL(18, 2),
           Balance       DECIMAL(18, 2)
        );

        INSERT INTO #TempTable
        (
           RowNumberDetail, 
           [Index],
           Date, 
           Agency, 
           Description, 
           Name,
           Details, 
           Type, 
           TicketNumber,
           Transactions,
  		     USD, 
           Fee1, 
           Fee2, 
           FeeServices, 
                    TicketId ,
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
        ,0 [Index]
       ,CAST(@FromDateInitial AS Date) Date
       ,Agency      
--      ,CAST(Usd AS VARCHAR(100))
       ,'INITIAL BALANCE'  Description 
       ,'' Name     
       ,'INITIAL BALANCE' Details
       ,0 Type
       ,''TicketNumber
       ,0 Transactions 
       ,0 USD
       ,0 Fee1 
       ,0 Fee2 
       ,0 FeeServices 
       ,0         TicketId 
       ,0 MoneyOrderFee
       ,0 Pago 
       ,Balance SumDetail
       ,Balance Balance 

      FROM dbo.[FN_GenerateBalanceTicketsDetails](NULL,@FromDateInitial,@AgencyId)
      ORDER BY RowNumberDetail DESC
      UNION ALL

      SELECT
        *
       FROM dbo.[FN_GenerateBalanceTicketsDetails](@FromDate,@ToDate,@AgencyId)
      WHERE Details != 'INITIAL BALANCE') AS Query;

       



   INSERT INTO #TempTable2 
  (
     RowNumber,
     RowNumberDetail, 
     [Index],
     Date, 
     Agency, 
     Description, 
     Name,
     Details, 
     Type, 
     TicketNumber,
     Transactions, 
     USD, 
     Fee1, 
     Fee2, 
     FeeServices, 
     TicketId,
     MoneyOrderFee, 
     Pago, 
     SumDetail, 
     Balance
  )

    SELECT
      *
    FROM (SELECT
        ROW_NUMBER() OVER (ORDER BY Query.Date,  Query.Type ASC
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