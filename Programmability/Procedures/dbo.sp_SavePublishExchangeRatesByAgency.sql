SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SavePublishExchangeRatesByAgency]
(@PublishExchangeRatesByAgencyId  INT            = NULL,

 @ConfirmDate   DATETIME,
 @AgencyId INT,
 @ConfirmBy INT 
)
AS
     BEGIN
           DECLARE @PublishExchangeRateId  INT           ;
		   SELECT TOP 1 @PublishExchangeRateId = PublishExchangeRateId FROM PublishExchangeRates
                 INSERT INTO [dbo].PublishExchangeRatesByAgency
                 (PublishExchangeRateId,
				 ConfirmDate,
				 AgencyId,                  
                 ConfirmBy
                 )
                 VALUES
                 (@PublishExchangeRateId,
				 @ConfirmDate,
				 @AgencyId,
                  @ConfirmBy
                 );
        
     END;
GO