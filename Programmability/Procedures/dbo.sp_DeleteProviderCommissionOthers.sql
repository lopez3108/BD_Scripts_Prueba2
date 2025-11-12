SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteProviderCommissionOthers]
 (
      @ProviderCommissionPaymentId INT
    )
AS 

BEGIN

DELETE FROM [dbo].[OtherCommissions]
      WHERE ProviderCommissionPaymentId = @ProviderCommissionPaymentId

	END
GO