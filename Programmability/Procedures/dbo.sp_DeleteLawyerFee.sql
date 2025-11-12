SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteLawyerFee]
(
	  @LawyerPaymentId int
)
AS 

BEGIN

	DELETE FROM [dbo].[LawyerPayments]
	WHERE LawyerPaymentId = @LawyerPaymentId

END
GO