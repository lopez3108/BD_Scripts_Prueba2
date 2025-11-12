SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_SeekReturnedCheckXChecks] @CheckElsId INT
AS
BEGIN
  DECLARE @hasReturnedCheck BIT = 0
--CHECK NUMBER Y ACCOUNT DEL CHECK ELS QUE SE ESTA TRATANDO DE ELIMINAR 
	--SELECT @accountEls = CE.Account,
 --      @checkNumberEls = ce.CheckNumber , @MakerId =  ce.MakerId
 --   FROM ChecksEls ce
 --   WHERE ce.CheckElsId = @CheckElsId

  --SET @checkNumberEls = (SELECT @accountEls = Account
  --    ce.CheckNumber
  --  FROM ChecksEls ce
  --  WHERE ce.CheckElsId = @CheckElsId)
  --SET @accountEls = (SELECT
  --    ce.Account
  --  FROM ChecksEls ce
  --  WHERE ce.CheckElsId = @CheckElsId)
    
  --    SET @MakerId = (SELECT
  --    ce.MakerId
  --  FROM ChecksEls ce
  --  WHERE ce.CheckElsId = @CheckElsId)


  --SI  EXISTE UN RETURNED CHECK LIGADO A UN CHEQUE CON SU ACCOUNT Y CHECK NUMBER O MAKER
  --IF EXISTS (SELECT TOP 1
  --      rc.ReturnedCheckId
  --    FROM ReturnedCheck rc
  --    WHERE (rc.CheckNumber = @checkNumberEls
  --    AND rc.Account = @accountEls AND @MakerId IS NULL) or 
	 -- (rc.CheckNumber = @checkNumberEls
  --    AND rc.Account = @accountEls AND rc.MakerId = @MakerId ))

  --JT task 5206, se pasa la validación a una fn ya que es usada en vairas partes diferentes 
    SET @hasReturnedCheck = dbo.[fn_GetReturnedCheckByCheckElsId](@CheckElsId)


  --SI  EXISTE UN RETURNED CHECK LIGADO A UN CHEQUE CON EL MAKER
--  IF EXISTS (SELECT TOP 1
--        rc.ReturnedCheckId
--      FROM ReturnedCheck rc
--      WHERE rc.MakerId = @MakerId)
--
--  BEGIN
--    SET @hasReturnedCheck = 1
--  END


SELECT
  @hasReturnedCheck

END


GO