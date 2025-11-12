SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- LASTUPDATEDBY JT 
-- date: 17-marzo-2024
-- task 5733 Comisión tickest debe restar el M. O.
-- task 6464 14-mayo de 2025 Error calculando valores de comisiones JF
CREATE   FUNCTION [dbo].[fn_GetCommissionTickets] (@AgencyId INT,
@Month INT,
@Year INT,
@ExisteComisionPagada BIT,
@CommissionPaymentId INT = NULL)
RETURNS DECIMAL(18, 2)
AS
BEGIN
  DECLARE @Temp TABLE (
    RowNumber INT
   ,Date DATE
   ,Type INT
   ,SumDetail DECIMAL(18, 2)
  );
  		   DECLARE @MaxDate DATE;
  SET @MaxDate = EOMONTH(DATEFROMPARTS(@Year, @Month, 1));

  INSERT INTO @Temp
    SELECT
      *
    FROM (SELECT
        ROW_NUMBER() OVER (ORDER BY CAST(Query.Date AS Date) ASC,
        Query.Type ASC) RowNumber
       ,*
      FROM (SELECT
          CAST(t.CreationDate AS Date) Date
         ,1 Type
         ,

          --  SE comenta el 8 de marzo SUM(t.Usd) por peticion de JOrge ( para los tikets del modulo no se tiene en cuenta el USD solo el el Fee1 y Fee2
          --                               (SUM(t.Usd) + SUM(t.Fee1) + SUM(t.Fee2)) SumDetail

          (SUM(t.Fee1) + SUM(t.Fee2)) SumDetail
        FROM Tickets t
        INNER JOIN Agencies A
          ON A.AgencyId = t.AgencyId
        WHERE A.AgencyId = @AgencyId
        AND CAST(DATEPART(MONTH, t.CreationDate) AS INT) = @Month
        AND CAST(DATEPART(YEAR, t.CreationDate) AS INT) = @Year
        GROUP BY A.Name
                ,A.AgencyId
                ,CAST(t.CreationDate AS Date)
        UNION ALL


        SELECT
          CAST(t.CreationDate AS Date) Date
         ,2 Type
         ,SUM(t.Usd) SumDetail
        FROM TicketFeeServices t
        INNER JOIN Agencies a
          ON a.AgencyId = t.AgencyId
        WHERE a.AgencyId = @AgencyId
        AND CAST(DATEPART(MONTH, t.CreationDate) AS INT) = @Month
        AND CAST(DATEPART(YEAR, t.CreationDate) AS INT) = @Year
        GROUP BY a.Name
                ,a.AgencyId
                ,CAST(t.CreationDate AS Date)




 UNION ALL
        SELECT
          CAST(t.CreationDate AS Date) Date
         ,3 Type   
         ,-(SUM(ISNULL(t.MoneyOrderFee, 0))) SumDetail
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
        --                           
        AND t.AgencyId = @AgencyId AND t.MoneyOrderFee IS NOT NULL
       AND ((t.ProviderCommissionPaymentId IS NULL AND -- Trae la consulta del año actual y mes actual y hacia atras 
           CAST(t.CreationDate AS DATE) <= @MaxDate AND @ExisteComisionPagada = 0) OR 
         (t.ProviderCommissionPaymentId = @CommissionPaymentId AND @ExisteComisionPagada = 1 
        AND t.ProviderCommissionPaymentId IS NOT NULL))
        GROUP BY a.Name
                ,MoneyOrderNumber
                ,t.MoneyOrderFee
                ,t.TransactionFee
                ,ba.BankAccountId
                ,cb.CardBankId
                ,t.AgencyId
                ,ba.AccountNumber
                ,cb.CardNumber
                ,CAST(t.CreationDate AS Date)
                ,UpdateToPendingDate

      


        UNION ALL
        SELECT
          CAST(t.CreationDate AS Date) Date
         ,3 Type
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
         AND ((t.ProviderCommissionPaymentId IS NULL AND  -- Trae la consulta del año actual y mes actual y hacia atras 
            CAST(t.CreationDate AS DATE) <= @MaxDate AND @ExisteComisionPagada = 0) OR 
         (t.ProviderCommissionPaymentId = @CommissionPaymentId AND @ExisteComisionPagada = 1 
        AND t.ProviderCommissionPaymentId IS NOT NULL))
        GROUP BY a.Name
                ,MoneyOrderNumber
                ,t.MoneyOrderFee
                ,t.TransactionFee
                ,ba.BankAccountId
                ,cb.CardBankId
                ,t.AgencyId
                ,ba.AccountNumber
                ,cb.CardNumber
                ,CAST(t.CreationDate AS Date)
                ,UpdateToPendingDate) AS Query) AS QueryFinal;
  DECLARE @TempBalance TABLE (
    RowNumber INT
   ,Date DATE
   ,Type INT
   ,SumDetail DECIMAL(18, 2)
   ,Balance DECIMAL(18, 2)
  );
  INSERT INTO @TempBalance
    SELECT
      *
     ,(SELECT
          SUM(t2.SumDetail)
        FROM @Temp t2
        WHERE t2.RowNumber <= T1.RowNumber)
      Balance
    FROM @Temp T1;
  DECLARE @Balance DECIMAL(18, 2);
  SET @Balance = (SELECT TOP 1
      Balance
    FROM @TempBalance
    ORDER BY RowNumber DESC);
  RETURN @Balance;
END;
GO