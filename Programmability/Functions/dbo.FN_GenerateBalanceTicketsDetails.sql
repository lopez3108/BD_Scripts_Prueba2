SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--CREATE : fELIPE
--CREATEDATE: 04-03-2024
--TASK 5667, Agregar balance inicial a los reportes Tickets y tickets details

-- LASTUPDATEDBY JT 
-- date: 17-marzo-2024
-- task 5732 Discriminar payments y poner debajo de su respectivo traffic ticket

-- LASTUPDATEDBY Sergio 
-- date: 12-abril-2024
-- task 5793 Agregar ticket number a los tipos traffic tickets y payments

--LASTUPDATEDBY JF ,TASK 5932, Valores comisiones trafic tickes no coinciden (Se quitó el USD de la suma)
--LASTUPDATEDBY JF ,TASK 6151, Ajustes reportes tickets
-- 2024-12-10 DJ/6236: Agregar valor transaction fee al reporte de trafic tickets  y banks




CREATE FUNCTION [dbo].[FN_GenerateBalanceTicketsDetails] (@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@AgencyId INT)

RETURNS @result TABLE (
  RowNumberDetail INT
,[Index] INT
 ,Date DATETIME
 ,Agency VARCHAR(1000)
 ,Description VARCHAR(1000)
 ,Name VARCHAR(1000)
 ,Details VARCHAR(1000)
 ,Type VARCHAR(1000)
,TicketNumber    VARCHAR(40) 
 ,Transactions INT
 ,USD DECIMAL(18, 2)
 ,Fee1 DECIMAL(18, 2)
 ,Fee2 DECIMAL(18, 2)
 ,FeeServices DECIMAL(18, 2)
 ,TicketId INT
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
    , [Index] INT
   ,Date DATETIME
   ,Agency VARCHAR(1000)
   ,Description VARCHAR(1000)
   ,Name VARCHAR(1000)
   ,Details VARCHAR(1000)
   ,Type VARCHAR(1000)
         ,     TicketNumber    VARCHAR(40)

   ,Transactions INT
   ,USD DECIMAL(18, 2)
   ,Fee1 DECIMAL(18, 2)
   ,Fee2 DECIMAL(18, 2)
   ,FeeServices DECIMAL(18, 2)
   ,TicketId INT
   ,MoneyOrderFee DECIMAL(18, 2)
   ,Pago DECIMAL(18, 2)
   ,SumDetail DECIMAL(18, 2)
  );



  INSERT INTO @TableReturn (RowNumberDetail,
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
  SumDetail)




    SELECT
      *
    FROM (SELECT
        ROW_NUMBER() OVER (
        ORDER BY Query.Type ASC,
        CAST(Query.Date AS Date) ASC, TicketId ASC,
        Id ASC) RowNumberDetail
        ,Id [Index]
       ,Date
       ,Agency
       ,Description
       ,Name
       ,Details
       ,Type
       ,TicketNumber
       ,Transactions
       ,USD
       ,Fee1
       ,Fee2
       ,FeeServices
       ,TicketId
       ,MoneyOrderFee
       ,Pago
       ,SumDetail

      FROM (SELECT
          3 Id
         ,CAST(t.CreationDate AS Date) Date
         ,A.Code Agency
         ,'CLOSING DAILY' Description
         ,U.Name
         ,'TRAFFIC TICKETS' Details
         ,3 Type
         ,t.TicketNumber  
         ,1 Transactions
         ,(t.USD) USD
         ,(t.Fee1) Fee1
         ,(t.Fee2) Fee2
         ,0 FeeServices
         ,t.TicketId TicketId
         ,0 MoneyOrderFee
         ,0 Pago
         ,((t.Fee1) + (t.Fee2)) SumDetail
--         ,((t.USD) + (t.Fee1) + (t.Fee2)) SumDetail SumDetail --Se quitó el USD de la suma 
        FROM Tickets t
        INNER JOIN Agencies A
          ON A.AgencyId = t.AgencyId
        INNER JOIN dbo.Users U
          ON U.UserId = t.CreatedBy
        WHERE A.AgencyId = @AgencyId
        AND ((CAST(t.CreationDate AS Date) >= CAST(@FromDate AS Date)
        OR @FromDate IS NULL)
        AND (CAST(t.CreationDate AS Date) <= CAST(@ToDate AS Date)
        OR @ToDate IS NULL))
        UNION ALL
        SELECT
          4 Id
         ,CAST(t.CreationDate AS Date) Date
         ,a.Code Agency   
            ,'CLOSING DAILY' AS Description
         ,US.Name
        ,'PAYMENT M.O ' + (CONVERT(NVARCHAR(50), t.UpdateToPendingDate, 110)) Details  
 
         ,3 Type
         ,t.TicketNumber
         ,1 Transactions
         ,0 USD
         ,0 Fee1
         ,0 Fee2
         ,0 FeeServices
         ,t.TicketId TicketId
         ,ISNULL(t.MoneyOrderFee, 0) MoneyOrderFee
         ,(t.USD) Pago
--         ,-((ISNULL(t.MoneyOrderFee, 0)) + (t.USD)) SumDetail SumDetail --Se quitó el USD de la suma 
         ,-(ISNULL(t.MoneyOrderFee, 0))  SumDetail
        FROM Tickets t
        --          INNER JOIN  Users u  ON u.UserId = t.UpdateToPendingBy
        INNER JOIN Agencies a
          ON a.AgencyId = t.AgencyId
        LEFT JOIN dbo.BankAccounts ba
          ON ba.BankAccountId = t.BankAccountId
        LEFT JOIN dbo.CardBanks cb
          ON cb.CardBankId = t.CardBankId
        INNER JOIN dbo.Users US
          ON US.UserId = t.UpdateToPendingBy
        WHERE UpdateToPendingDate IS NOT NULL
        AND t.AgencyId = @AgencyId AND t.MoneyOrderFee IS NOT NULL
        AND ((CAST(t.CreationDate AS Date) >= CAST(@FromDate AS Date)
        OR @FromDate IS NULL)
        AND (CAST(t.CreationDate AS Date) <= CAST(@ToDate AS Date)
        OR @ToDate IS NULL))


  UNION ALL
        SELECT
          4 Id
         ,CAST(t.CreationDate AS Date) Date
         ,a.Code Agency   
            ,'CLOSING DAILY' AS Description
         ,US.Name     
         ,'PAYMENT ACH'+ ' ' + (CONVERT(NVARCHAR(50), t.UpdateToPendingDate, 110) + '    ' + '****' + ba.AccountNumber) Details 
 
         ,3 Type
         ,t.TicketNumber
         ,1 Transactions
         ,0 USD
         ,0 Fee1
         ,0 Fee2
         ,0 FeeServices
         ,t.TicketId TicketId
         ,ISNULL(t.TransactionFee, 0) MoneyOrderFee
         ,(t.USD) Pago
         ,-(ISNULL(t.TransactionFee, 0))  SumDetail
        FROM Tickets t
        INNER JOIN Agencies a
          ON a.AgencyId = t.AgencyId
        LEFT JOIN dbo.BankAccounts ba
          ON ba.BankAccountId = t.BankAccountId
        LEFT JOIN dbo.CardBanks cb
          ON cb.CardBankId = t.CardBankId
        INNER JOIN dbo.Users US
          ON US.UserId = t.UpdateToPendingBy
        WHERE UpdateToPendingDate IS NOT NULL
        AND t.AgencyId = @AgencyId  AND t.AchUsd IS NOT NULL
        AND ((CAST(t.CreationDate AS Date) >= CAST(@FromDate AS Date)
        OR @FromDate IS NULL)
        AND (CAST(t.CreationDate AS Date) <= CAST(@ToDate AS Date)
        OR @ToDate IS NULL))

        UNION ALL
        SELECT
          2 Id
         ,CAST(t.CreationDate AS Date) Date
         ,a.Code Agency
         ,'CLOSING DAILY' Description
         ,U.Name
         ,'FEE SERVICES' Details
         ,2 Type
         ,'' TicketNumber
         ,(t.Plus) Transactions
         ,0 USD
         ,0 Fee1
         ,0 Fee2
         ,(t.USD) FeeServices
         ,0 TicketId
         ,0 MoneyOrderFee
         ,0 Pago
         ,(t.USD) SumDetail
        FROM TicketFeeServices t
        INNER JOIN Agencies a
          ON a.AgencyId = t.AgencyId
        INNER JOIN dbo.Users U
          ON U.UserId = t.CreatedBy
        WHERE a.AgencyId = @AgencyId
        AND ((CAST(t.CreationDate AS Date) >= CAST(@FromDate AS Date)
        OR @FromDate IS NULL)
        AND (CAST(t.CreationDate AS Date) <= CAST(@ToDate AS Date)
        OR @ToDate IS NULL))



        UNION ALL
        SELECT
          1 Id
         ,dbo.[fn_GetNextDayPeriod](ProviderCommissionPayments.year, ProviderCommissionPayments.Month) Date
         ,dbo.Agencies.Code
         ,'COMM. ' + dbo.[fn_GetMonthByNum](ProviderCommissionPayments.Month) + '-' + CAST(ProviderCommissionPayments.Year AS CHAR(4)) Description
         ,'' Name
         ,'COMMISSIONS' Details
         ,1 Type
         ,'' TicketNumber
         ,1 Transactions
         ,0 USD
         ,0 Fee1
         ,0 Fee2
         ,0 FeeServices
         ,0 TicketId
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
        AND ProviderCommissionPayments.ProviderId = @ProviderId) AS Query) AS QueryFinal
    ORDER BY RowNumberDetail ASC;

  INSERT INTO @result (RowNumberDetail,
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