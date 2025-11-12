SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- ==========================JT Función para consultar un cheque retornado por check elsid===============
CREATE FUNCTION [dbo].[fn_GetReturnedCheckByCheckElsId] 
(
	@CheckElsId int
)
RETURNS BIT
AS
BEGIN

declare @checkNumberEls VARCHAR(50)
         ,@accountEls VARCHAR(30)
         ,@hasReturnedCheck BIT = 0
         ,@MakerId  INT;

	SELECT @accountEls = CE.Account,
       @checkNumberEls = ce.CheckNumber , @MakerId =  ce.MakerId
    FROM ChecksEls ce
    WHERE ce.CheckElsId = @CheckElsId

	  IF EXISTS (SELECT TOP 1
        rc.ReturnedCheckId
      FROM ReturnedCheck rc
      WHERE (rc.CheckNumber = @checkNumberEls
      AND rc.Account = @accountEls AND @MakerId IS NULL) or 
	  (rc.CheckNumber = @checkNumberEls
      AND rc.Account = @accountEls AND rc.MakerId = @MakerId ))

  BEGIN
    SET @hasReturnedCheck = 1
  END

RETURN @hasReturnedCheck

END
GO