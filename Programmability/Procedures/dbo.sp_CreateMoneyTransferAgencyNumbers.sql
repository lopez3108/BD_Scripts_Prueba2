SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreateMoneyTransferAgencyNumbers] @AgencyId INT
, @ProviderId INT
, @Number VARCHAR(10) = NULL
--@InitialBalance decimal(18,2) = null,
--@ConfigurationSavedDate DATETIME = null
AS
BEGIN


  DECLARE @result INT
  SET @result = 0

  IF (@Number IS NULL)
  BEGIN


    IF (EXISTS (SELECT
          dbo.MoneyTransferxAgencyNumbers.ProviderId
        FROM dbo.MoneyDistribution
        INNER JOIN dbo.MoneyTransferxAgencyNumbers
          ON dbo.MoneyDistribution.MoneyTransferxAgencyNumbersId = dbo.MoneyTransferxAgencyNumbers.MoneyTransferxAgencyNumbersId
        WHERE dbo.MoneyTransferxAgencyNumbers.ProviderId = @ProviderId
        AND dbo.MoneyTransferxAgencyNumbers.AgencyId = @AgencyId)
      )
    BEGIN


      SET @result = -3

    END
    ELSE
    BEGIN


      DELETE [dbo].[MoneyTransferxAgencyNumbers]
      WHERE AgencyId = @AgencyId
        AND ProviderId = @ProviderId

      SET @result = @ProviderId


    END


  END
  ELSE
  BEGIN
    IF (@result >= 0)
    BEGIN



      DECLARE @MoneyTransferAgencyNumberId INT

      IF (EXISTS (SELECT
            *
          FROM [dbo].[MoneyTransferxAgencyNumbers]
          WHERE AgencyId = @AgencyId
          AND ProviderId = @ProviderId)
        )
      BEGIN

        SET @MoneyTransferAgencyNumberId = (SELECT TOP 1
            MoneyTransferxAgencyNumbersId
          FROM [dbo].[MoneyTransferxAgencyNumbers]
          WHERE AgencyId = @AgencyId
          AND ProviderId = @ProviderId)

        UPDATE [dbo].[MoneyTransferxAgencyNumbers]
        SET [AgencyId] = @AgencyId
           ,[ProviderId] = @ProviderId
           ,[Number] = @Number
--           InitialBalance = @InitialBalance,
--           ConfigurationSavedDate = @ConfigurationSavedDate
        WHERE MoneyTransferxAgencyNumbersId = @MoneyTransferAgencyNumberId

        SET @result = 1

      END
      ELSE
      BEGIN


        INSERT INTO [dbo].[MoneyTransferxAgencyNumbers] ([AgencyId]
        , [ProviderId]
        , [Number])
          VALUES (@AgencyId, @ProviderId, @Number
--          @InitialBalance,@ConfigurationSavedDate
          )

        SET @MoneyTransferAgencyNumberId = (SELECT
            @@identity)

      END


      SET @result = @MoneyTransferAgencyNumberId





    END

  END

  SELECT
    @result


END;

GO