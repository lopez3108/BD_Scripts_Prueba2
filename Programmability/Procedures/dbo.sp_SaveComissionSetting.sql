SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-01-17 JF/6293: Habilitar comisiones insurance a los cajeros para los nuevos servicios

CREATE PROCEDURE [dbo].[sp_SaveComissionSetting] (@ComissionSettingId INT = NULL,
@CitySticker DECIMAL(18, 2),
@PlateSticker DECIMAL(18, 2),
@ParkingTicket DECIMAL(18, 2),
@ParkingTicketCard DECIMAL(18, 2),
@TitlesAndPlates DECIMAL(18, 2),
@TitlesAndPlatesManual DECIMAL(18, 2),
@Trp730 DECIMAL(18, 2),
@Financing DECIMAL(18, 2),
@Telephones DECIMAL(18, 2),
@Notary DECIMAL(18, 2),
@Lendify DECIMAL(18, 2) = 0,
@Tickets DECIMAL(18, 2),
@NewPolicy DECIMAL(18, 2),
@MonthlyPayment DECIMAL(18, 2),
@RegistrationRelease DECIMAL(18, 2),
@Endorsement DECIMAL(18, 2),
@PolicyRenewal DECIMAL(18, 2),
@IdCreated INT OUTPUT)
AS
BEGIN
  IF (@ComissionSettingId IS NULL)
  BEGIN
    INSERT INTO [dbo].ComissionSettings (CitySticker,
    PlateSticker,
    ParkingTicket,
    ParkingTicketCard,
    TitlesAndPlates,
    TitlesAndPlatesManual,
    Trp730,
    Financing,
    Telephones,
    Notary,
    Lendify,
    Tickets,
    NewPolicy,
    MonthlyPayment,
    RegistrationRelease,
    Endorsement,
    PolicyRenewal)
      VALUES (@CitySticker, @PlateSticker, @ParkingTicket, @ParkingTicketCard, @TitlesAndPlates, @TitlesAndPlatesManual, @Trp730, @Financing, @Telephones, @Notary, @Lendify,
      @Tickets, @NewPolicy, @MonthlyPayment, @RegistrationRelease,@Endorsement,@PolicyRenewal);
    SET @IdCreated = @@IDENTITY;
  END;
  ELSE
  BEGIN
    UPDATE [dbo].ComissionSettings
    SET CitySticker = @CitySticker
       ,PlateSticker = @PlateSticker
       ,ParkingTicket = @ParkingTicket
       ,ParkingTicketCard = @ParkingTicketCard
       ,TitlesAndPlates = @TitlesAndPlates
       ,Telephones = @Telephones
       ,TitlesAndPlatesManual = @TitlesAndPlatesManual
       ,Trp730 = @Trp730
       ,Financing = @Financing
       ,Notary = @Notary
       ,Lendify = @Lendify
       ,Tickets = @Tickets
       ,NewPolicy = @NewPolicy
       ,MonthlyPayment = @MonthlyPayment
       ,RegistrationRelease = @RegistrationRelease
       ,Endorsement = @Endorsement
       ,PolicyRenewal = @PolicyRenewal
    WHERE ComissionSettingId = @ComissionSettingId;
    SET @IdCreated = @ComissionSettingId;
  END;
END;


GO