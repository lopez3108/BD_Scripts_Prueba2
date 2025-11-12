SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_SaveComisionLendifySetting] (@LendifyCompany DECIMAL(18, 2))
AS
BEGIN


  DECLARE @id INT;
  SET @id = (SELECT TOP 1
      ComissionSettingId
    FROM ComissionSettings)

  IF (@id IS NULL)
  BEGIN
    INSERT INTO ComissionSettings (
--    CitySticker,
--    PlateSticker,
--ParkingTicket,
--ParkingTicketCard,
--TitlesAndPlates,
--TitlesAndPlatesManual,
--Trp730,
--Financing,
--Telephones,
--Notary,
--Lendify,

    LendifyCompany
--    Tickets
    )
      VALUES (
--      0,
--    0,
--0,
--0,
--0,
--0,
--0,
--0,
--0,
--0,
--0,

    @LendifyCompany
--    0
      )
  END
  ELSE
  BEGIN
    UPDATE  ComissionSettings
    SET LendifyCompany = @LendifyCompany
    WHERE ComissionSettingId = @id
  END
END;
GO