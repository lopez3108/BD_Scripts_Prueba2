SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_IsCheckReturned](@CheckNumber   VARCHAR(50))
RETURNS BIT
--WITH RETURNS NULL ON NULL INPUT
AS
     BEGIN
         

	

	IF(EXISTS(SELECT * FROM ReturnedCheck WHERE CheckNumber = @CheckNumber))
	BEGIN

	declare @client BIT
	set @client = (SELECT TOP 1 ClientBlocked FROM ReturnedCheck WHERE CheckNumber = @CheckNumber)

	declare @maker BIT
	set @maker = (SELECT TOP 1 MakerBlocked FROM ReturnedCheck WHERE CheckNumber = @CheckNumber)

	declare @account BIT
	set @account = (SELECT TOP 1 AccountBlocked FROM ReturnedCheck WHERE CheckNumber = @CheckNumber)

	IF(@client = CAST(1 as BIT) OR @maker = CAST(1 as BIT) OR @account = CAST(1 as BIT))
	BEGIN

	RETURN CAST(1 as BIT)

	END
	ELSE
	BEGIN

	RETURN CAST(0 as BIT)


	END


	END


	RETURN CAST(0 as BIT)


	END
GO