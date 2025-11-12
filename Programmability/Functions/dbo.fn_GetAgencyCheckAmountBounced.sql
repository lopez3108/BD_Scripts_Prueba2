SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
CREATE   FUNCTION [dbo].[fn_GetAgencyCheckAmountBounced] 
(
	@AgencyId int,
	@Date datetime
)
RETURNS decimal (18,2)
AS
BEGIN

declare @result int

set @result = ISNULL((SELECT SUM(Checks.Amount)
FROM            Checks INNER JOIN
                         Agencies ON Checks.AgencyId = Agencies.AgencyId
						 WHERE Agencies.AgencyId = @AgencyId AND CAST(Checks.DateCashed as DATE) = CAST(@Date as DATE)),0)

RETURN @result

END
GO