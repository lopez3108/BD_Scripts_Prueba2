SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-03-24 Carlos/5761: Employee commissions payment

CREATE PROCEDURE [dbo].[sp_SaveExpense] (@ExpenseId INT = NULL,
@ExpenseTypeId INT = NULL,
@ExpenseTypeCode VARCHAR(10) = NULL,
@Description VARCHAR(200) = NULL,
@Usd DECIMAL(18, 2),
@BillTypeId INT = NULL,
@MonthsId INT = NULL,
@Year INT = NULL,
@ReceiptNumber VARCHAR(50) = NULL,
@ProviderName VARCHAR(50) = NULL,
@ProviderId INT = NULL,
@Company VARCHAR(50) = NULL,
@TransactionNumber VARCHAR(15) = NULL,
@Sender VARCHAR(50) = NULL,
@Recipient VARCHAR(50) = NULL,
@Quantity INT = NULL,
@MoneyOrderNumber VARCHAR(20) = NULL,
@AgencyId INT,
@CreatedBy INT,
@CreatedOn DATETIME,
@Validated BIT = NULL,
@ValidatedBy INT = NULL,
@IdCreated INT OUTPUT,
@CashierId INT = NULL,
@RefundCashierId INT = NULL,
@RefundSurplusDate DATETIME = NULL,
@PlateSticker DECIMAL(18, 2),
@PlateStickerCommission DECIMAL(18, 2),
@CitySticker DECIMAL(18, 2),
@CityStickerCommission DECIMAL(18, 2),
@Notary DECIMAL(18, 2),
@NotaryCommission DECIMAL(18, 2),
@Telephones DECIMAL(18, 2),
@TelephonesCommission DECIMAL(18, 2),
@TitlesAndPlates DECIMAL(18, 2),
@TitlesAndPlatesCommission DECIMAL(18, 2),
@TitlesAndPlatesManual DECIMAL(18, 2),
@TitlesAndPlatesManualCommission DECIMAL(18, 2),
@Trp730 DECIMAL(18, 2),
@Trp730Commissions DECIMAL(18, 2),
@Financing DECIMAL(18, 2),
@FinancingCommission DECIMAL(18, 2),
@ParkingTicket DECIMAL(18, 2),
@ParkingTicketCommission DECIMAL(18, 2),
@ParkingTicketCard DECIMAL(18, 2),
@ParkingTicketCardCommission DECIMAL(18, 2),
@Lendify DECIMAL(18, 2),
@LendifyCommission DECIMAL(18, 2),
@Tickets DECIMAL(18, 2),
@TicketsCommission DECIMAL(18, 2),
@UpdatedBy INT = NULL,
@UpdatedOn DATETIME = NULL,
@ValidatedOn DATETIME = NULL,
@FileIdNameExpenses VARCHAR(500) = NULL)
AS
BEGIN
  SET @ExpenseTypeId = (SELECT
      ExpensesTypeId
    FROM ExpensesType
    WHERE Code = @ExpenseTypeCode);
  IF (@ExpenseId IS NULL)
  BEGIN
    INSERT INTO [dbo].[Expenses] (ExpenseTypeId,
    Description,
    Usd,
    BillTypeId,
    MonthsId,
    Year,
    ReceiptNumber,
    ProviderName,
    ProviderId,
    Company,
    TransactionNumber,
    Sender,
    Recipient,
    Quantity,
    MoneyOrderNumber,
    AgencyId,
    CreatedBy,
    CreatedOn,
    RefundCashierId,
    RefundSurplusDate,
    CashierId,
    PlateSticker,
    PlateStickerCommission,
    CitySticker,
    CityStickerCommission,
    Notary,
    NotaryCommission,
    Telephones,
    TelephonesCommission,
    TitlesAndPlates,
    TitlesAndPlatesCommission,
    TitlesAndPlatesManual,
    TitlesAndPlatesManualCommission,
    Trp730,
    Trp730Commissions,
    Financing,
    FinancingCommission,
    ParkingTicket,
    ParkingTicketCommission,
    ParkingTicketCard,
    ParkingTicketCardCommission,
    Lendify,
    LendifyCommission,
    Tickets,
    TicketsCommission,
    UpdatedBy,
    UpdatedOn,
    FileIdNameExpenses,
    ValidatedOn)
      VALUES (@ExpenseTypeId, @Description, @Usd, @BillTypeId, @MonthsId, @Year, @ReceiptNumber, @ProviderName, @ProviderId, @Company, @TransactionNumber, @Sender, @Recipient, @Quantity, @MoneyOrderNumber, @AgencyId, @CreatedBy, @CreatedOn, @RefundCashierId, @RefundSurplusDate, @CashierId, @PlateSticker, @PlateStickerCommission, @CitySticker, @CityStickerCommission, @Notary, @NotaryCommission, @Telephones, @TelephonesCommission, @TitlesAndPlates, @TitlesAndPlatesCommission, @TitlesAndPlatesManual, @TitlesAndPlatesManualCommission, @Trp730, @Trp730Commissions, @Financing, @FinancingCommission, @ParkingTicket, @ParkingTicketCommission, @ParkingTicketCard, @ParkingTicketCardCommission, @Lendify, @LendifyCommission, @Tickets, @TicketsCommission, @UpdatedBy, @UpdatedOn, @FileIdNameExpenses, @ValidatedOn);
    SET @IdCreated = @@IDENTITY;

    -- 5761 Cuando se paga comision de empleados se deben actualizar todos los movimientos que fueron pagados con dicha commissión
    IF (@ExpenseTypeCode = 'C10')
    BEGIN

      DECLARE @paid BIT
      SET @paid = CAST(1 AS BIT)

      EXEC dbo.sp_UpdateEmployeeCommissionsPaid @CashierId
                                               ,@AgencyId
                                               ,@IdCreated
                                               ,NULL

    END

  END;
  ELSE
  BEGIN
    UPDATE [dbo].[Expenses]
    SET ExpenseTypeId = @ExpenseTypeId
       ,Description = @Description
       ,USD = @Usd
       ,BillTypeId = @BillTypeId
       ,MonthsId = @MonthsId
       ,Year = @Year
       ,ReceiptNumber = @ReceiptNumber
       ,ProviderName = @ProviderName
       ,ProviderId = @ProviderId
       ,Company = @Company
       ,TransactionNumber = @TransactionNumber
       ,Sender = @Sender
       ,Recipient = @Recipient
       ,Quantity = @Quantity
       ,MoneyOrderNumber = @MoneyOrderNumber
       ,Validated = @Validated
       ,ValidatedBy = @ValidatedBy
       ,ValidatedOn = @ValidatedOn
       ,RefundCashierId = @RefundCashierId
       ,RefundSurplusDate = @RefundSurplusDate
       ,CashierId = @CashierId
       ,PlateSticker = @PlateSticker
       ,PlateStickerCommission = @PlateStickerCommission
       ,CitySticker = @CitySticker
       ,CityStickerCommission = @CityStickerCommission
       ,Notary = @Notary
       ,NotaryCommission = @NotaryCommission
       ,Telephones = @Telephones
       ,TelephonesCommission = @TelephonesCommission
       ,TitlesAndPlates = @TitlesAndPlates
       ,TitlesAndPlatesCommission = @TitlesAndPlatesCommission
       ,TitlesAndPlatesManual = @TitlesAndPlatesManual
       ,TitlesAndPlatesManualCommission = @TitlesAndPlatesManualCommission
       ,Trp730 = @Trp730
       ,Trp730Commissions = @Trp730Commissions
       ,Financing = @Financing
       ,FinancingCommission = @FinancingCommission
       ,ParkingTicket = @ParkingTicket
       ,ParkingTicketCommission = @ParkingTicketCommission
       ,ParkingTicketCard = @ParkingTicketCard
       ,ParkingTicketCardCommission = @ParkingTicketCardCommission
       ,Lendify = @Lendify
       ,LendifyCommission = @LendifyCommission
       ,Tickets = @Tickets
       ,TicketsCommission = @TicketsCommission
       ,UpdatedBy = @UpdatedBy
       ,UpdatedOn = @UpdatedOn
       ,FileIdNameExpenses = @FileIdNameExpenses
    WHERE ExpenseId = @ExpenseId;
    SET @IdCreated = @ExpenseId;
  END;
END;
GO