SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeletePublishExchangeRatesByAgency]
(@PublishExchangeRatesByAgencyId  INT            = NULL
)
AS
     BEGIN
    
	DELETE FROM PublishExchangeRatesByAgency where PublishExchangeRatesByAgencyId = @PublishExchangeRatesByAgencyId or @PublishExchangeRatesByAgencyId is null;
           
            
        
     END;
GO