SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Update  Felipe oquendo
--task 5550 CASH ADVANCE OR BACK SENT 11-28-2023
--date: 02-12-2023
--Se agregaron dos campos UseCashAdvanceOrBack , CashAdvanceOrBackVoucherRequired 
CREATE PROCEDURE [dbo].[sp_CreateProvider] (@ProviderId INT = NULL, @Name VARCHAR(50), @ProviderTypeId INT,
@AcceptNegative BIT = NULL, @Active BIT = NULL, @Comision DECIMAL(18, 2) = NULL,
@ShowInBalance BIT = 0, @IdSaved INT OUTPUT, @CheckCommission DECIMAL(18, 2) = NULL,
@MoneyOrderCommission DECIMAL(18, 2) = NULL, @ReturnedCheckCommission DECIMAL(18, 2) = NULL,
@CostAndCommission BIT = 0, @DetailedTransaction BIT = 0, @LimitBalance BIT = 0,
@MoneyOrderService BIT = 0, @UseSmartSafeDeposit BIT = 0, @SmartSafeDepositVoucherRequired BIT = 0,
@UseCashAdvanceOrBack BIT = 0, @CashAdvanceOrBackVoucherRequired BIT = 0, @ForexType INT = NULL)
AS
BEGIN

  SET @IdSaved = 0

  IF (@ProviderId IS NULL)
  BEGIN
    INSERT INTO [dbo].[Providers] ([Name],
    [ProviderTypeId],
    [AcceptNegative],
    [Comision],
    [Active],
    [ShowInBalance],
    CheckCommission,
    MoneyOrderCommission,
    ReturnedCheckCommission,
    CostAndCommission,
    DetailedTransaction,
    LimitBalance,
    MoneyOrderService,
    UseSmartSafeDeposit,
    SmartSafeDepositVoucherRequired,
    UseCashAdvanceOrBack,
    CashAdvanceOrBackVoucherRequired,
    ForexType)
      VALUES (@Name, @ProviderTypeId, @AcceptNegative, @Comision, @Active, @ShowInBalance, @CheckCommission, @MoneyOrderCommission, @ReturnedCheckCommission, @CostAndCommission, @DetailedTransaction, @LimitBalance, @MoneyOrderService, @UseSmartSafeDeposit, @SmartSafeDepositVoucherRequired, @UseCashAdvanceOrBack, @CashAdvanceOrBackVoucherRequired, @ForexType);
    SET @IdSaved = @@IDENTITY;
  END;
  ELSE
  BEGIN

    DECLARE @currentActiveBill BIT
    SET @currentActiveBill = (SELECT TOP 1
        Active
      FROM Providers p
      WHERE p.ProviderId = @ProviderId)
    ---------------------------

    IF (CAST(@Active AS BIT) = 0
      AND CAST(@currentActiveBill AS BIT) = 1)
    BEGIN

      IF (EXISTS (SELECT TOP 1
            *
          FROM dbo.GeneralNotes gn
          WHERE gn.ProviderId = @ProviderId)
        )
      BEGIN

        SET @IdSaved = -5;

      END

    END
    ---------------------------

    DECLARE @providerTypeCode VARCHAR(5)
    SET @providerTypeCode = (SELECT TOP 1
        dbo.ProviderTypes.Code
      FROM dbo.Providers
      INNER JOIN dbo.ProviderTypes
        ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
      WHERE dbo.Providers.ProviderId = @ProviderId)

    IF (@providerTypeCode = 'C01')
    BEGIN



      --			 SET @currentActiveBill = (SELECT TOP 1 Active FROM Providers p WHERE p.ProviderId = @ProviderId)
      IF (CAST(@Active AS BIT) = 0
        AND CAST(@currentActiveBill AS BIT) = 1)
      BEGIN

        IF (EXISTS (SELECT
              *
            FROM dbo.PaymentBalance p
            WHERE p.ProviderId = @ProviderId
            AND dbo.fn_GetPaymentBalanceIsPending(p.PaymentBalanceId) = CAST(1 AS BIT))
          )
        BEGIN

          SET @IdSaved = -4;

        END



      END


    END


    DECLARE @currentLimitBalance BIT
    SET @currentLimitBalance = (SELECT TOP 1
        dbo.Providers.LimitBalance
      FROM dbo.Providers
      WHERE dbo.Providers.ProviderId = @ProviderId)
    DECLARE @currentActive BIT
    SET @currentActive = (SELECT TOP 1
        dbo.Providers.Active
      FROM dbo.Providers
      WHERE dbo.Providers.ProviderId = @ProviderId)

    IF (@providerTypeCode = 'C02'
      AND @currentLimitBalance <> @LimitBalance
      AND EXISTS (SELECT
          dbo.MoneyTransferxAgencyNumbers.ProviderId
        FROM dbo.MoneyDistribution
        INNER JOIN dbo.MoneyTransferxAgencyNumbers
          ON dbo.MoneyDistribution.MoneyTransferxAgencyNumbersId = dbo.MoneyTransferxAgencyNumbers.MoneyTransferxAgencyNumbersId
        WHERE dbo.MoneyTransferxAgencyNumbers.ProviderId = @ProviderId)
      )
    BEGIN
      SET @IdSaved = -1;
    END
    ELSE
    IF (@providerTypeCode = 'C02'
      AND @currentActive <> @Active
      AND EXISTS (SELECT
          dbo.MoneyTransferxAgencyNumbers.ProviderId
        FROM dbo.MoneyDistribution
        INNER JOIN dbo.MoneyTransferxAgencyNumbers
          ON dbo.MoneyDistribution.MoneyTransferxAgencyNumbersId = dbo.MoneyTransferxAgencyNumbers.MoneyTransferxAgencyNumbersId
        WHERE dbo.MoneyTransferxAgencyNumbers.ProviderId = @ProviderId)
      )
    BEGIN
      SET @IdSaved = -2;
    END
    ELSE
    BEGIN

      IF (@IdSaved <> -4
        AND @IdSaved <> -5)
      BEGIN
        UPDATE [dbo].[Providers]
        SET [Name] = @Name
           ,
            --                               [ProviderTypeId] = @ProviderTypeId,
            [AcceptNegative] = @AcceptNegative
           ,[Comision] = @Comision
           ,[Active] = @Active
           ,[ShowInBalance] = @ShowInBalance
           ,CheckCommission = @CheckCommission
           ,MoneyOrderCommission = @MoneyOrderCommission
           ,ReturnedCheckCommission = @ReturnedCheckCommission
           ,CostAndCommission = @CostAndCommission
           ,DetailedTransaction = @DetailedTransaction
           ,LimitBalance = @LimitBalance
           ,MoneyOrderService = @MoneyOrderService
           ,UseSmartSafeDeposit = @UseSmartSafeDeposit
           ,SmartSafeDepositVoucherRequired = @SmartSafeDepositVoucherRequired
           ,UseCashAdvanceOrBack = @UseCashAdvanceOrBack
           ,CashAdvanceOrBackVoucherRequired = @CashAdvanceOrBackVoucherRequired
           ,ForexType = @ForexType
        WHERE ProviderId = @ProviderId;
        SET @IdSaved = @ProviderId;
      END

    END

  END;

END;


GO