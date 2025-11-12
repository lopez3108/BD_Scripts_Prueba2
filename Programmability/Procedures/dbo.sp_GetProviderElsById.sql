SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- Create By:      Felipe
-- Creation Date:  08-Abril-2024
-- Task:  Query the ExpenseId and CashierCommission of the ( CitySticke,PlateSticker,Titles,Lendify,TRP,TicketFeeService)         

CREATE PROCEDURE [dbo].[sp_GetProviderElsById] (@Id INT, @Code VARCHAR(4))
AS



BEGIN
  IF (@Code = 'C01')
  BEGIN

    SELECT
    ISNULL(cs.ExpenseId, 0) ExpenseId,
    ISNULL(cs.CashierCommission, 0) CashierCommission      
     
    FROM CityStickers cs
    WHERE cs.CityStickerId = @Id

  END ELSE
  IF (@Code = 'C02')
  BEGIN

    SELECT
      ISNULL(ps.ExpenseId, 0) ExpenseId,
      ISNULL(ps.CashierCommission, 0) CashierCommission     
    FROM PlateStickers ps
    WHERE ps.PlateStickerId = @Id

  END ELSE
  IF (@Code = 'C03')
  BEGIN

    SELECT
      ISNULL(t.ExpenseId, 0) ExpenseId,
      ISNULL(t.CashierCommission, 0) CashierCommission
     
    FROM Titles t
    WHERE t.TitleId = @Id

  END ELSE
   IF (@Code = 'C04')
  BEGIN

    SELECT
      ISNULL(t.ExpenseId, 0) ExpenseId,
      ISNULL(t.CashierCommission, 0) CashierCommission
     
    FROM TRP t
    WHERE t.TRPId = @Id

  END ELSE 
  IF (@Code = 'C05')
  BEGIN

    SELECT
      ISNULL(ps.ExpenseId, 0) ExpenseId,
      ISNULL(ps.CashierCommission, 0) CashierCommission
     
    FROM PhoneSales ps 
    WHERE ps.PhoneSalesId = @Id

  END ELSE 
  IF (@Code = 'C06')
  BEGIN

    SELECT
     ISNULL(l.ExpenseId, 0) ExpenseId   
    FROM Lendify l
    WHERE l.LendifyId = @Id

  END ELSE 
  IF (@Code = 'C07')
  BEGIN

    SELECT
    ISNULL(t.ExpenseId, 0) ExpenseId,
    ISNULL(t.CashierCommission, 0) CashierCommission
         
    FROM TicketFeeServiceDetails t
    WHERE t.TicketFeeServiceDetailsId = @Id

  END ELSE
   IF (@Code = 'C08')
  BEGIN

    SELECT
    ISNULL(t.ExpenseId, 0) ExpenseId,
    ISNULL(t.CashierCommission, 0) CashierCommission
         
    FROM Tickets t
    WHERE t.TicketId = @Id

  END




END;



GO