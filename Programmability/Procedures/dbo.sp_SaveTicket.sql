SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Nombre:  sp_SaveTicket				    															         
-- Descripcion: Procedimiento Almacenado que guardad el ticket por Id.				    					         
-- Creado por: 																				 
-- Fecha: 																									 	
-- Modificado por: Diego León Acevedo Arenas																										 
-- Fecha: 2023-07-24																											 
-- Observación:  Se agregan los campos Tollway, Others, PlateNumber, StateAbre  y se remueve el campo TicketDate, ClientAddress   
-- Test: EXECUTE [dbo].[sp_SaveTicket] @TicketId = 1705                                      
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 20204-11-06 DJ/6127: Pay Tickets using ACH
-- 20204-11-12 JF/6186: Validar pagos de Traffic tickets de PENDING SHIPPING A PENDIG
-- 20204-11-28 LF/6229: Ajustes formulario traffic tickets
-- 20204-12-09 DJ/6234: Nuevo campo TRANSACTION FEE para los pagos ACH
-- 20205-02-20 JT/5939: Nuevo campo @TransactionGuid para identificar varios tickets dentro de una misma tranasction
-- 2025-04-16  LF/6457: Nuevo campo Client Language of Preference (Idioma de Preferencia del Cliente)
-- 2025-04-22  JF/6447: Permitir editar tickets usd

CREATE PROCEDURE [dbo].[sp_SaveTicket] (@TicketId INT = NULL,
@TicketStatusId INT = NULL,
@TicketStatusIdSaved INT = NULL,
@StatusCode VARCHAR(10) = NULL,
@TicketNumber VARCHAR(30) = NULL,
@Usd DECIMAL(18, 2) = NULL,
@AgencyId INT = NULL,
@CreatedBy INT = NULL,
@CreationDate DATETIME = NULL,
@CompletedBy INT = NULL,
@CompletedDate DATETIME = NULL,
@ClientName VARCHAR(70) = NULL,
@ClientTelephone VARCHAR(12) = NULL,
@Fee1 DECIMAL(18, 2) = NULL,
@Fee2 DECIMAL(18, 2) = NULL,
--                                       @ExpirationDate DATETIME = NULL,
@UpdateToPendingDate DATETIME = NULL,
@UpdateToPendingBy INT = NULL,
@UpdateToPendingShippingDate DATETIME = NULL,
@UpdateToPendingShippingBy INT = NULL,
@MoneyOrderNumber VARCHAR(20) = NULL,
@CardBankId INT = NULL,
@BankAccountId INT = NULL,
@TicketsPaymentTypeCode VARCHAR(10) = NULL,
@CityCompletedDate DATE = NULL,
@MoneyOrderFee DECIMAL(18, 2) = NULL,
@FileImageName VARCHAR(MAX) = NULL,
@MoFileImageName VARCHAR(MAX) = NULL,
@TicketPaymentTypeId INT = NULL,
@IdCreated INT OUTPUT,
@ChangedToPendingByAgency INT = NULL,
@CardPayment BIT,
@CardPaymentFee DECIMAL(18, 2) = NULL,
@TelIsCheck BIT = NULL,
@LastUpdatedOn DATETIME = NULL,
@LastUpdatedBy INT = NULL,
@Cash DECIMAL(18, 2) = NULL,
@Tollway BIT = 0,
@OthersTicket BIT = 0,
@PlateNumberTicket VARCHAR(10) = NULL,
@StateAbre NVARCHAR(255) = NULL,
@FileNameOthers VARCHAR(MAX) = NULL,
@CashierCommission DECIMAL(18, 2) = NULL,
@AchUsd DECIMAL(18, 2) = NULL,
@TransactionId VARCHAR(36) = NULL,
@UpdatedToPendingByAdmin BIT = 0,
@TransactionFee DECIMAL(18, 2) = NULL,
@TransactionGuid UNIQUEIDENTIFIER = NULL,
@ClientLanguage BIT,
@Fee2DefaultUsd DECIMAL(18, 2) = NULL,
@UsdGreaterValue DECIMAL(18, 2) = NULL,
@UsdLessEqualValue DECIMAL(18, 2) = NULL)
AS
  DECLARE @MoneyOrderFeeIn DECIMAL(18, 2) = NULL
         ,@currentTicketStatusId INT;
  BEGIN
    SET @TicketStatusId = (SELECT
        TicketStatusId
      FROM TicketStatus
      WHERE Code = @StatusCode);



    IF (@TicketId IS NULL)
    BEGIN
      INSERT INTO [dbo].Tickets (TicketNumber,
      Usd,
      TicketStatusId,
      CreatedBy,
      CreationDate,
      AgencyId,
      ClientName,
      ClientTelephone,
      Fee1,
      Fee2,
      -- ExpirationDate, comentado por task 6229
      FileImageName,
      MoFileImageName,
      TicketPaymentTypeId,
      CardPayment,
      CardPaymentFee,
      TelIsCheck,
      LastUpdatedOn,
      LastUpdatedBy,
      Cash,
      UpdateToPendingShippingBy,
      UpdateToPendingShippingDate,
      Tollway,
      Others,
      PlateNumber,
      StateAbre,
      FileNameOthers,
      CashierCommission,
      TransactionGuid,
      ClientLanguage,
      Fee2DefaultUsd,
      UsdGreaterValue,
      UsdLessEqualValue)
        VALUES (@TicketNumber, @Usd, @TicketStatusId, @CreatedBy, @CreationDate, @AgencyId, @ClientName, @ClientTelephone, @Fee1, @Fee2,
        --                    @ExpirationDate,comentado por task 6229
        @FileImageName, @MoFileImageName, @TicketPaymentTypeId, @CardPayment, @CardPaymentFee, @TelIsCheck, @LastUpdatedOn, @LastUpdatedBy, @Cash, @UpdateToPendingShippingBy, @UpdateToPendingShippingDate, @Tollway, @OthersTicket, @PlateNumberTicket, @StateAbre, @FileNameOthers, @CashierCommission,
           @TransactionGuid,@ClientLanguage,@Fee2DefaultUsd,@UsdGreaterValue,@UsdLessEqualValue);
      SET @IdCreated = @@IDENTITY;
    END;
    ELSE
    BEGIN

      SET @currentTicketStatusId = (SELECT TOP 1
          t.TicketStatusId
        FROM dbo.Tickets t
        WHERE t.TicketId = @TicketId)


      IF (@currentTicketStatusId = @TicketStatusId
        AND @TicketStatusIdSaved <> @currentTicketStatusId)
      BEGIN
        SELECT
          @IdCreated = -2;
      END
      ELSE
      IF (ISNULL(@TransactionFee, 0) > (ISNULL(@Fee1, 0) + ISNULL(@Fee2, 0)))
      BEGIN

        SELECT
          @IdCreated = -3;

      END
      ELSE
      IF (@MoneyOrderFee IS NOT NULL)
      BEGIN
        SET @MoneyOrderFeeIn = @MoneyOrderFee;
      END;
      IF (@TicketsPaymentTypeCode = 'C01'
        AND @StatusCode = 'C01')
      BEGIN
        IF (@MoneyOrderFee IS NULL)
        BEGIN
          SET @MoneyOrderFeeIn = (SELECT TOP 1
              MoneyOrderFee
            FROM [dbo].[ConfigurationELS]);
          SET @CardBankId = NULL;
          SET @BankAccountId = NULL;
        END;
      END;
      IF (@TicketsPaymentTypeCode = 'C02'
        AND @StatusCode = 'C01')
      BEGIN
        SET @MoneyOrderNumber = NULL;
        SET @MoneyOrderFee = NULL;
        SET @BankAccountId = NULL;
      END;
      IF (@TicketsPaymentTypeCode = 'C03'
        AND @StatusCode = 'C01')
      BEGIN
        SET @MoneyOrderNumber = NULL;
        SET @MoneyOrderFee = NULL;
        SET @CardBankId = NULL;
      END;


      IF (@TicketsPaymentTypeCode = 'C04'
        AND @StatusCode = 'C01')
      BEGIN
-- Se comenta por que ya no es nesario consultar de la bd este valor anterior 
--        DECLARE @ticketUsd DECIMAL(18, 2)
--
--        SET @ticketUsd = (SELECT TOP 1
--            t.Usd
--          FROM dbo.Tickets t
--          WHERE t.TicketId = @TicketId)

        IF (@AchUsd <> @Usd)
        BEGIN
          SET @IdCreated = -1;
        END
      END;

      IF (@IdCreated >= 0
        OR @IdCreated IS NULL)
      BEGIN

        UPDATE [dbo].Tickets
        SET TicketStatusId = @TicketStatusId
           ,CompletedBy = @CompletedBy
           ,CompletedDate = @CompletedDate
           ,ClientName = @ClientName
           ,ClientTelephone = @ClientTelephone
           ,Fee1 = @Fee1
           ,Fee2 = @Fee2
            -- ExpirationDate = @ExpirationDate, comentado por task 6229
           ,UpdateToPendingDate = @UpdateToPendingDate
           ,UpdateToPendingBy = @UpdateToPendingBy
           ,UpdateToPendingShippingDate = @UpdateToPendingShippingDate
           ,UpdateToPendingShippingBy = @UpdateToPendingShippingBy
           ,MoneyOrderFee = @MoneyOrderFeeIn
           ,MoneyOrderNumber = @MoneyOrderNumber
           ,CardBankId = @CardBankId
           ,BankAccountId = @BankAccountId
           ,CityCompletedDate = @CityCompletedDate
           ,FileImageName = @FileImageName
           ,MoFileImageName = @MoFileImageName
           ,TicketPaymentTypeId = @TicketPaymentTypeId
           ,ChangedToPendingByAgency = @ChangedToPendingByAgency
           ,CardPayment = @CardPayment
           ,CardPaymentFee = @CardPaymentFee
           ,TelIsCheck = @TelIsCheck
           ,LastUpdatedOn = @LastUpdatedOn
           ,LastUpdatedBy = @LastUpdatedBy
           ,Cash = @Cash
           ,Tollway = @Tollway
           ,Others = @OthersTicket
           ,PlateNumber = @PlateNumberTicket
           ,StateAbre = @StateAbre
           ,FileNameOthers = @FileNameOthers
           ,AchUsd = @AchUsd
           ,TransactionId = @TransactionId
           ,UpdatedToPendingByAdmin = @UpdatedToPendingByAdmin
           ,TransactionFee = @TransactionFee
           ,ClientLanguage =@ClientLanguage
           ,Usd = @Usd
        WHERE TicketId = @TicketId;

        SET @IdCreated = @TicketId;

      END
    END;
  END;












GO