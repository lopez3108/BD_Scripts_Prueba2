SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*CREADO POR ROMARIO JIMENEZ 22/11/2023 TASK:5521
*/
CREATE PROCEDURE [dbo].[sp_UpdateCashForAdmin] 
@ExtraFundId INT = NULL,
@CompletedBy INT = NULL,
@CompletedOn DATETIME = NULL

AS
BEGIN


  UPDATE ExtraFund
  SET completed = 1, CompletedBy = @CompletedBy,CompletedOn=@CompletedOn  WHERE ExtraFundId = @ExtraFundId
END
GO