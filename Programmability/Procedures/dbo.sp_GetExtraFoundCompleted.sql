SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetExtraFoundCompleted]
@ExtraFundId      INT  = NULL
AS
BEGIN

  SELECT
    ef.*
  FROM ExtraFund ef
  WHERE ef.ExtraFundId = @ExtraFundId

END
GO