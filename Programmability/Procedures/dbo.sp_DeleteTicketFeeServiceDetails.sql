SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteTicketFeeServiceDetails] (@TicketFeeServiceDetailsId INT)
AS
BEGIN
  
  DELETE TicketFeeServiceDetails
  WHERE TicketFeeServiceDetailsId = @TicketFeeServiceDetailsId;
END;

GO