SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SavePublishExchangeRates] (@PublishExchangeRateId INT = NULL,
@CreationDate DATETIME,
@PublishBy INT,
@Value DECIMAL(18, 2))
AS
BEGIN

  INSERT INTO [dbo].PublishExchangeRates (CreationDate,
  PublishBy,
  value)
    VALUES (@CreationDate, @PublishBy, @Value);

END;
GO