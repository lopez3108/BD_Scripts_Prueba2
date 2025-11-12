SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CalculateDueReturned](@ReturnedCheckId   INT)
RETURNS DECIMAL(18, 2)
--WITH RETURNS NULL ON NULL INPUT
AS
     BEGIN
         

		 DECLARE @paid DECIMAL(18,2)
			SET @paid = ISNULL((SELECT SUM(Usd) FROM [dbo].[ReturnPayments] WHERE ReturnedCheckId = @ReturnedCheckId),0)

			DECLARE @due DECIMAL(18,2)
			SET @due = 
			((SELECT (USD + Fee) FROM [dbo].[ReturnedCheck] WHERE ReturnedCheckId = @ReturnedCheckId) +
			ISNULL((SELECT SUM(Usd) FROM CourtPayment WHERE ReturnedCheckId = @ReturnedCheckId),0) +
			ISNULL((SELECT SUM(Usd) FROM LawyerPayments WHERE ReturnedCheckId = @ReturnedCheckId),0))

			DECLARE @currentDue DECIMAL(18,2)
			SET @currentDue = @due - @paid

			IF(@currentDue < 0)
			BEGIN

			SET  @currentDue = 0

			END
			
			RETURN ISNULL(@currentDue,0)

     END;
GO