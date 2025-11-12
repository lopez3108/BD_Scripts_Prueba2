SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
CREATE FUNCTION [dbo].[fn_GetContractStatus] 
(
	@ContractId int,
	@Date datetime
)
RETURNS varchar(10)
AS
BEGIN

declare @result varchar(10)
declare @finalDate DATETIME

declare @status VARCHAR(5)
(SELECT        @status = dbo.ContractStatus.Code, @finalDate = EndDate
FROM            dbo.Contract INNER JOIN
                         dbo.ContractStatus ON dbo.Contract.Status = dbo.ContractStatus.ContractStatusId WHERE ContractId = @ContractId)

IF(@status = 'C01')
BEGIN

IF(CAST(@finalDate as DATE) < CAST(@Date as DATE))
BEGIN

SET @result = 'EXPIRED'

END
ELSE
BEGIN

SET @result = 'ACTIVE'

END

END
ELSE IF (@status = 'C02')
BEGIN

SET @result = 'CLOSED'


END
ELSE
BEGIN

SET @result = 'CANCELED'


END

RETURN @result

END
GO