SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- Create Felipe 
-- date: 3-marzo-2024
-- task 5667 Agregar balance inicial a los reportes Tickets y tickets details

-- LASTUPDATEDBY JT 
-- date: 17-marzo-2024
-- task 5732 Discriminar payments y poner debajo de su respectivo traffic ticket
-- Correct order 1-Initial balance 2-Commissions 3-Fee services 4-Trafic tickets 5- Payments

--LASTUPDATEDBY JF ,TASK 5932, Valores comisiones trafic tickes no coinciden (Se quitó el USD de la suma)
--LASTUPDATEDBY JF ,TASK 6151, Ajustes reportes tickets
-- 2024-12-10 DJ/6236: Agregar valor transaction fee al reporte de trafic tickets  y banks


CREATE FUNCTION [dbo].[FN_GenerateBalanceTickets] (@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@AgencyId INT) --1 = INITIAL BALANDE 2= ANOTHER
RETURNS @result TABLE (
  RowNumberDetail INT
 ,Date DATETIME
 ,Agency VARCHAR(1000)
 ,Description VARCHAR(1000)
 ,Details VARCHAR(1000)
 ,Type VARCHAR(1000)
 ,Transactions INT
 ,USD DECIMAL(18, 2)
 ,Fee1 DECIMAL(18, 2)
 ,Fee2 DECIMAL(18, 2)
 ,FeeServices DECIMAL(18, 2)
 ,MoneyOrderFee DECIMAL(18, 2)
 ,Pago DECIMAL(18, 2)
 ,SumDetail DECIMAL(18, 2)
 ,Balance DECIMAL(18, 2)

)
AS
BEGIN

  DECLARE @ProviderId AS INT;

  SET @ProviderId = (SELECT
      ProviderId
    FROM Providers
    INNER JOIN ProviderTypes
      ON Providers.ProviderTypeId = ProviderTypes.ProviderTypeId
    WHERE ProviderTypes.Code = 'C24');


  DECLARE @TableReturn TABLE (
    RowNumberDetail INT
   ,Date DATETIME
   ,Agency VARCHAR(1000)
   ,Description VARCHAR(1000)
   ,Details VARCHAR(1000)
   ,Type VARCHAR(1000)
   ,Transactions INT
   ,USD DECIMAL(18, 2)
   ,Fee1 DECIMAL(18, 2)
   ,Fee2 DECIMAL(18, 2)
   ,FeeServices DECIMAL(18, 2)
   ,MoneyOrderFee DECIMAL(18, 2)
   ,Pago DECIMAL(18, 2)
   ,SumDetail DECIMAL(18, 2)
  );

  INSERT INTO @TableReturn (RowNumberDetail,
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
  SumDetail)
    SELECT
      *
    FROM (SELECT
        ROW_NUMBER() OVER (
        ORDER BY Query.Type ASC,
        CAST(Query.Date AS DATETIME) ASC) RowNumberDetail
       ,Query.Date
       ,Query.Agency
       ,Query.Description
       ,Query.Details
       ,Query.Type
       ,SUM(Query.Transactions) Transactions
       ,SUM(Query.USD) USD
       ,SUM(Query.Fee1) Fee1
       ,SUM(Query.Fee2) Fee2
       ,SUM(Query.FeeServices) FeeServices
       ,SUM(Query.MoneyOrderFee) MoneyOrderFee
       ,SUM(Query.Pago) Pago
       ,SUM(Query.SumDetail) SumDetail
      FROM (SELECT
          CAST(t.CreationDate AS Date) Date
         ,A.Code Agency
         ,'CLOSING DAILY' Description
         ,'TRAFFIC TICKETS' Details
         ,3 Type
         ,COUNT(*) Transactions
         ,SUM(t.Usd) USD
         ,SUM(t.Fee1) Fee1
         ,SUM(t.Fee2) Fee2
         ,0 FeeServices
         ,0 MoneyOrderFee
         ,0 Pago
--         ,(SUM(t.Usd) + SUM(t.Fee1) + SUM(t.Fee2)) SumDetail --Se quitó el USD de la suma 
         ,(SUM(t.Fee1) + SUM(t.Fee2)) SumDetail
        FROM Tickets t
        INNER JOIN Agencies A
          ON A.AgencyId = t.AgencyId
        WHERE A.AgencyId = @AgencyId
        AND ((CAST(t.CreationDate AS Date) >= CAST(@FromDate AS Date)
        OR @FromDate IS NULL)
        AND (CAST(t.CreationDate AS Date) <= CAST(@ToDate AS Date)
        OR @ToDate IS NULL))
        GROUP BY A.Name
                ,A.Code
                ,A.AgencyId
                ,CAST(t.CreationDate AS Date)
        UNION ALL
        SELECT
          CAST(t.CreationDate AS Date) Date
         ,a.Code Agency
         ,'CLOSING DAILY' Description
         ,'FEE SERVICES' Details
         ,2 Type
         ,SUM(t.Plus) Transactions
         ,0 USD
         ,0 Fee1
         ,0 Fee2
         ,SUM(t.Usd) FeeServices
         ,0 MoneyOrderFee
         ,0 Pago
         ,SUM(t.Usd) SumDetail
        FROM TicketFeeServices t
        INNER JOIN Agencies a
          ON a.AgencyId = t.AgencyId
        WHERE a.AgencyId = @AgencyId
        AND ((CAST(t.CreationDate AS Date) >= CAST(@FromDate AS Date)
        OR @FromDate IS NULL)
        AND (CAST(t.CreationDate AS Date) <= CAST(@ToDate AS Date)
        OR @ToDate IS NULL))

        GROUP BY a.Name
                ,a.Code
                ,a.AgencyId
                ,CAST(t.CreationDate AS Date)
        UNION ALL
        SELECT
          CAST(t.CreationDate AS DATETIME) Date
         ,a.Code Agency      
          ,'CLOSING DAILY' AS Description
         ,'PAYMENT M.O ' + (CONVERT(NVARCHAR(50), t.UpdateToPendingDate, 110)) Details 

--         ,'PAYMENT ' + (CONVERT(NVARCHAR(50), t.UpdateToPendingDate, 110)) Details
         ,4 Type
         ,1 Transactions
         ,0 USD
         ,0 Fee1
         ,0 Fee2
         ,0 FeeServices
         ,ISNULL(t.MoneyOrderFee, 0) MoneyOrderFee
         ,(t.Usd) Pago
         ,-(ISNULL(t.MoneyOrderFee, 0))  SumDetail
--         ,-((ISNULL(t.MoneyOrderFee, 0)) + (t.Usd)) SumDetail --Se quitó el USD de la suma 
        FROM Tickets t
        INNER JOIN Users u
          ON u.UserId = t.UpdateToPendingBy
        INNER JOIN Agencies a
          ON a.AgencyId = t.ChangedToPendingByAgency
        LEFT JOIN dbo.BankAccounts ba
          ON ba.BankAccountId = t.BankAccountId
        LEFT JOIN dbo.CardBanks cb
          ON cb.CardBankId = t.CardBankId
        WHERE UpdateToPendingDate IS NOT NULL
        AND t.AgencyId = @AgencyId AND t.MoneyOrderFee IS NOT NULL
        AND ((CAST(t.CreationDate AS Date) >= CAST(@FromDate AS Date)
        OR @FromDate IS NULL)
        AND (CAST(t.CreationDate AS Date) <= CAST(@ToDate AS Date)
        OR @ToDate IS NULL))



   UNION ALL
        SELECT
          CAST(t.CreationDate AS DATETIME) Date
         ,a.Code Agency      
          ,'CLOSING DAILY' AS Description
         ,'PAYMENT ACH'+ ' ' + (CONVERT(NVARCHAR(50), t.UpdateToPendingDate, 110) + ' ' + '****' + ba.AccountNumber) Details 
         ,4 Type
         ,1 Transactions
         ,0 USD
         ,0 Fee1
         ,0 Fee2
         ,0 FeeServices
         ,ISNULL(t.TransactionFee, 0) MoneyOrderFee
         ,(t.Usd) Pago
         ,-(ISNULL(t.TransactionFee, 0))  SumDetail
        FROM Tickets t
        INNER JOIN Users u
          ON u.UserId = t.UpdateToPendingBy
        INNER JOIN Agencies a
          ON a.AgencyId = t.AgencyId
        LEFT JOIN dbo.BankAccounts ba
          ON ba.BankAccountId = t.BankAccountId
        LEFT JOIN dbo.CardBanks cb
          ON cb.CardBankId = t.CardBankId
        WHERE UpdateToPendingDate IS NOT NULL
        AND t.AgencyId = @AgencyId AND t.AchUsd IS NOT NULL
        AND ((CAST(t.CreationDate AS Date) >= CAST(@FromDate AS Date)
        OR @FromDate IS NULL)
        AND (CAST(t.CreationDate AS Date) <= CAST(@ToDate AS Date)
        OR @ToDate IS NULL))





        UNION ALL
        SELECT
          dbo.[fn_GetNextDayPeriod](Year, Month) Date
         ,dbo.Agencies.Code
         ,'COMM. ' + dbo.[fn_GetMonthByNum](ProviderCommissionPayments.Month) + '-' + CAST(ProviderCommissionPayments.Year AS CHAR(4)) Description
         ,'COMMISSIONS' Details
         ,1 Type
         ,1 Transactions
         ,0 USD
         ,0 Fee1
         ,0 Fee2
         ,0 FeeServices
         ,0 MoneyOrderFee
         ,ISNULL(ProviderCommissionPayments.Usd, 0) Pago
         ,-ISNULL(ProviderCommissionPayments.Usd, 0) SumDetail

        FROM dbo.ProviderCommissionPayments
        INNER JOIN dbo.Providers
          ON dbo.ProviderCommissionPayments.ProviderId = dbo.Providers.ProviderId
        INNER JOIN dbo.ProviderCommissionPaymentTypes
          ON dbo.ProviderCommissionPayments.ProviderCommissionPaymentTypeId = dbo.ProviderCommissionPaymentTypes.ProviderCommissionPaymentTypeId
        INNER JOIN dbo.Agencies
          ON dbo.ProviderCommissionPayments.AgencyId = dbo.Agencies.AgencyId
        LEFT OUTER JOIN dbo.Bank
          ON dbo.ProviderCommissionPayments.BankId = dbo.Bank.BankId
        INNER JOIN dbo.ProviderTypes
          ON dbo.ProviderTypes.ProviderTypeId = dbo.Providers.ProviderTypeId
        WHERE ProviderCommissionPayments.AgencyId = @AgencyId
        AND (dbo.[fn_GetNextDayPeriod](Year, Month) >= CAST(@FromDate AS Date)
        OR @FromDate IS NULL)
        AND (dbo.[fn_GetNextDayPeriod](Year, Month) <= CAST(@ToDate AS Date)
        OR @ToDate IS NULL)

        AND ProviderCommissionPayments.ProviderId = @ProviderId

		


      --Comentado por la tarea 4336 
      --AND 
      --GROUP BY a.Name, 
      --         MoneyOrderNumber, 
      --         t.MoneyOrderFee, 
      --         ba.BankAccountId, 
      --         cb.CardBankId, 
      --         A.AgencyId, 
      --         A.code, 
      --         ba.AccountNumber, 
      --         cb.CardNumber, 
      --         CAST(t.UpdateToPendingDate AS DATE)
      ) AS Query


      GROUP BY Agency
              ,Date
              ,Description
              ,Details
              ,Type) AS QueryFinal



    ORDER BY RowNumberDetail DESC;


  INSERT INTO @result (RowNumberDetail,
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
  Balance)
    (
    SELECT
      *
     ,(SELECT
          SUM(t2.SumDetail)
        FROM @TableReturn t2
        WHERE t2.RowNumberDetail <= t1.RowNumberDetail)
      Balance
    FROM @TableReturn t1
    );

  RETURN;
END;


GO