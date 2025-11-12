SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteMoneyTransferAgencyNumbers] 
@ProviderId INT
AS
     BEGIN


	 IF(EXISTS
                   (
                       SELECT dbo.MoneyTransferxAgencyNumbers.ProviderId
                       FROM dbo.MoneyDistribution
                            INNER JOIN dbo.MoneyTransferxAgencyNumbers ON dbo.MoneyDistribution.MoneyTransferxAgencyNumbersId = dbo.MoneyTransferxAgencyNumbers.MoneyTransferxAgencyNumbersId
                       WHERE dbo.MoneyTransferxAgencyNumbers.ProviderId = @ProviderId
                   ))
				   BEGIN


				   SELECT -3

				   END
         ELSE
		 BEGIN

DELETE FROM [dbo].[MoneyTransferxAgencyNumbers]
      WHERE ProviderId = @ProviderId


	  END








     END;


GO