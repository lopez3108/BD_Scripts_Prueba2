SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteAllExchangeRateByCountryId] (@CountryId INT)

AS
BEGIN

  DECLARE @ExchangeRate BIT
--  IF EXISTS (SELECT
--        *
--      FROM ExchangeRates er
--      WHERE er.CountryId = @CountryId)
    --                            
    --                            	
    --                            
    --                            END;
      SET @ExchangeRate = (SELECT
          COUNT(*)
    
        FROM ExchangeRates er
        WHERE er.CountryId = @CountryId)

    IF @ExchangeRate = 1
    BEGIN



      UPDATE Countries
      SET Currency = NULL
      WHERE CountryId = @CountryId;

      DELETE FROM ExchangeRates
      WHERE CountryId = @CountryId;
    END
  IF @ExchangeRate = 0

  BEGIN
    UPDATE Countries
    SET Currency = NULL
    WHERE CountryId = @CountryId;
  END;
END
GO