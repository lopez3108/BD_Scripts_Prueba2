SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CalculatePaidReturned](@ReturnedCheckId   INT)
RETURNS DECIMAL(18, 2)
--WITH RETURNS NULL ON NULL INPUT
AS
     BEGIN
         

		 DECLARE @paid DECIMAL(18,2)
			SET @paid = (SELECT SUM(Usd) FROM [dbo].[ReturnPayments] WHERE ReturnedCheckId = @ReturnedCheckId)

			
			
			RETURN ISNULL(@paid, 0)

     END;
GO