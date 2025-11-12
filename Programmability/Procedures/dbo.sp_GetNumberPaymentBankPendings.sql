SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--UPDATE Felipe oquendo
--task 5532 AJUSTES GENERALES SENT 11-18-2023
--date: 30-11-2023

CREATE PROCEDURE [dbo].[sp_GetNumberPaymentBankPendings](@UserId AS INT)
AS
     BEGIN
      
         SELECT 
		 COUNT(*) PaymentBankCount
		 FROM dbo.[PaymentBanks] p
         WHERE P.Status = 1 
--         AND (P.CreatedBy = @UserId )
           
		     
     END;


GO