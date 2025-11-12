SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetReturnPaymentBalance] @ReturnedCheckId INT, @Date DATETIME
AS
     BEGIN
        
		SELECT dbo.fn_CalculateDueReturnedByDate (@ReturnedCheckId, @Date)


     END;
GO