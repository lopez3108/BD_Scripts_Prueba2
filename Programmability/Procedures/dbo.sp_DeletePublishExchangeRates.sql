SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeletePublishExchangeRates]
(@PublishExchangeRateId  INT            = NULL
)
AS
     BEGIN
    
	DELETE FROM PublishExchangeRates WHERE PublishExchangeRateId = @PublishExchangeRateId OR @PublishExchangeRateId IS NULL;
           
            
        
     END;
GO