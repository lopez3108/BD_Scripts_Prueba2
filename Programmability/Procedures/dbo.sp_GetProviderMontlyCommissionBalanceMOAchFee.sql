SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- task 6632 09-junio de 2025 Comisiones tickets JF

CREATE PROCEDURE [dbo].[sp_GetProviderMontlyCommissionBalanceMOAchFee] (@AgencyId INT,
@Month INT,
@Year INT,
@ProviderTypeCode VARCHAR(4))
AS
BEGIN

  		   DECLARE @MaxDate DATE;
  SET @MaxDate = EOMONTH(DATEFROMPARTS(@Year, @Month, 1));

  IF (@ProviderTypeCode = 'C24')
  BEGIN
    -- TICKETS

    SELECT

      t.TicketId
     ,t.MoneyOrderFee AS MOAchFee
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
    AND t.AgencyId = @AgencyId
    AND t.MoneyOrderFee IS NOT NULL
    AND t.MoneyOrderFee > 0
     AND (t.ProviderCommissionPaymentId IS NULL AND -- Trae la consulta del año actual y mes actual y hacia atras 
           CAST(t.CreationDate AS DATE) <= @MaxDate) 
        


    UNION ALL

    SELECT
      t.TicketId
     ,t.TransactionFee AS MOAchFee
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
    AND t.AgencyId = @AgencyId
    AND t.AchUsd IS NOT NULL
    AND t.TransactionFee > 0
     AND (t.ProviderCommissionPaymentId IS NULL AND -- Trae la consulta del año actual y mes actual y hacia atras 
           CAST(t.CreationDate AS DATE) <= @MaxDate) 

  END;

END;
GO