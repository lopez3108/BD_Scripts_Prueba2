SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
CREATE FUNCTION [dbo].[fn_GetConciliationCardPaymentTotal] 
(
	@ConciliationCardPaymentId int
)
RETURNS decimal (18,2)
AS
BEGIN

declare @result decimal(18,2)

set @result = ISNULL((SELECT SUM(Usd) FROM ConciliationCardPaymentsDetails
						 WHERE ConciliationCardPaymentId = @ConciliationCardPaymentId),0)

RETURN @result

END
GO