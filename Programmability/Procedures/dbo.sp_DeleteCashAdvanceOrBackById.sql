SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Create  Felipe oquendo
--task 5550 CASH ADVANCE OR BACK SENT 11-28-2023
--date: 02-12-2023
--Descripcion : Elimina el registro de Cash Advance OR Back BY Id

CREATE PROCEDURE [dbo].[sp_DeleteCashAdvanceOrBackById](@CashAdvanceOrBackId INT)
AS
     BEGIN
		 DELETE FROM dbo.CashAdvanceOrBack
		 WHERE
			CashAdvanceOrBackId = @CashAdvanceOrBackId
         
     END;
GO