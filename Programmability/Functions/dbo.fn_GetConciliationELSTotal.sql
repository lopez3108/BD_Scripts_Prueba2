SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
CREATE FUNCTION [dbo].[fn_GetConciliationELSTotal] 
(
	@ConciliationELSId int
)
RETURNS decimal (18,2)
AS
BEGIN

declare @result decimal(18,2)

set @result = ISNULL((SELECT SUM(Usd) FROM ConciliationELSDetails
						 WHERE ConciliationELSId = @ConciliationELSId),0)

RETURN @result

END
GO