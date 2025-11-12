SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveExchangeRates]
(@ExchangeRateId   INT            = NULL,
@CountryId        INT,
@ProviderId      INT,
@Payer           varchar(70),
@Usd            DECIMAL(18, 2),
@LastUpdatedBy INT    ,
@LastUpdatedOn   DATETIME,
@IdCreated      INT OUTPUT  
)
AS
     BEGIN
         IF(@ExchangeRateId IS NULL)
             BEGIN
                 INSERT INTO [dbo].ExchangeRates
                 (
                  CountryId,
                  ProviderId,
                  Usd,
				  Payer,                  
                  LastUpdatedBy,
                  LastUpdatedOn
                 )
                 VALUES
                 (
                  @CountryId,
                  @ProviderId,
				  @Usd,
                  @Payer,
                  @LastUpdatedBy,
                  @LastUpdatedOn
                 );
                 SET @IdCreated = @@IDENTITY;
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].ExchangeRates
                   SET                      
				  CountryId =  @CountryId,
                  ProviderId = @ProviderId,
				  Usd = @Usd,
                  Payer = @Payer,
                  LastUpdatedBy = @LastUpdatedBy,
                  LastUpdatedOn = @LastUpdatedOn
                 WHERE ExchangeRateId = @ExchangeRateId;
                 SET @IdCreated = @ExchangeRateId;
         END;
     END;
GO