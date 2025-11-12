SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
CREATE FUNCTION [dbo].[fn_GetReturnCheckPaidDate] 
(
	@ReturnedCheckId int
)
RETURNS DATETIME
AS
BEGIN

declare @result datetime

set @result = (SELECT TOP 1 CreationDate FROM ReturnPayments WHERE ReturnedCheckId = @ReturnedCheckId
ORDER BY CreationDate DESC)

RETURN @result

END
GO