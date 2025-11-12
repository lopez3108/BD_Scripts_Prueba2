SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CalculateDueReturnedByDate](@ReturnedCheckId   INT, @Date DATETIME)
RETURNS DECIMAL(18, 2)
--WITH RETURNS NULL ON NULL INPUT
AS
     BEGIN
         

		 DECLARE @paid DECIMAL(18,2)
			SET @paid = (SELECT SUM(Usd) FROM [dbo].[ReturnPayments] WHERE 
			ReturnedCheckId = @ReturnedCheckId AND
			CAST(CreationDate as date) <= CAST(@Date as DATE))

			declare @toPaid decimal(18,2)
			set @toPaid = (SELECT USD + Fee FROM ReturnedCheck WHERE ReturnedCheckId = @ReturnedCheckId)

			
			
			RETURN ISNULL(@toPaid - @paid, 0)

     END;
GO