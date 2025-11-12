SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_Delete@FinancingMessage](@FinancingMessageId INT)
AS
     BEGIN
         DELETE FinancingMessages
         WHERE FinancingMessageId = @FinancingMessageId;
	    SELECT 1;
     END;
GO