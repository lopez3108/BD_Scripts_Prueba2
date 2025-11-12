SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteCourtFee]
(
	  @CourtPaymentId int
)
AS 

BEGIN

	DELETE FROM [dbo].[CourtPayment]
	WHERE CourtPaymentId = @CourtPaymentId

END
GO