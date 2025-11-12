SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteExchangeRate](@ExchangeRateId INT)
AS
     BEGIN
         DELETE FROM ExchangeRates
         WHERE ExchangeRateId = @ExchangeRateId;
     END;
GO