SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CalculatePaidReturnedByDate](@ReturnedCheckId   INT, @Date DATETIME)
RETURNS DECIMAL(18, 2)
--WITH RETURNS NULL ON NULL INPUT
AS
     BEGIN
         

		 DECLARE @paid DECIMAL(18,2)
			SET @paid = (SELECT SUM(Usd) FROM [dbo].[ReturnPayments] WHERE 
			ReturnedCheckId = @ReturnedCheckId AND
			CreationDate <= @Date)

			
			
			RETURN ISNULL(@paid, 0)

     END;
GO