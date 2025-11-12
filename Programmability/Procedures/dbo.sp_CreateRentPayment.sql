SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-06-18 DJ/6589: Requerir ACH date para RENT PAYMENT y DEPOSIT MANAGEMENT
-- 2025-10-07 JF/6775: Permitir pagos con créditos y débitos

CREATE PROCEDURE [dbo].[sp_CreateRentPayment] (@ContractId INT,
@Usd DECIMAL(18, 2),
@UsdPayment DECIMAL(18, 2),
@CreationDate DATETIME,
@CreatedBy INT,
@AgencyId INT = NULL,
@CardPayment BIT,
@CardPaymentFee DECIMAL(18, 2) = NULL,
@FeeDue DECIMAL(18, 2) = NULL,
@Cash DECIMAL(18, 2) = NULL,
@FeeDuePending DECIMAL(18, 2),
@BankAccountId INT = NULL,
@RentPending DECIMAL(18, 2),
@InitialBalance DECIMAL(18, 2),
@FinalBalance DECIMAL(18, 2),
@MoveInFee DECIMAL(18, 2),
@AchDate DATETIME = NULL,
@IsCredit BIT = NULL)
AS
BEGIN
  INSERT INTO [dbo].[RentPayments] ([ContractId],
  [Usd],
  [UsdPayment],
  [CreationDate],
  [CreatedBy],
  [AgencyId],
  CardPayment,
  CardPaymentFee,
  FeeDue,
  Cash,
  BankAccountId,
  FeeDuePending,
  RentPending,
  InitialBalance,
  FinalBalance,
  MoveInFee,
  AchDate,
  IsCredit)
    VALUES (@ContractId, @Usd, @UsdPayment, @CreationDate, @CreatedBy, @AgencyId, @CardPayment, @CardPaymentFee, 
       @FeeDue, @Cash, @BankAccountId, @FeeDuePending, @RentPending, @InitialBalance, @FinalBalance, @MoveInFee, @AchDate,@IsCredit);
  INSERT INTO [dbo].[ContractNotes] ([ContractId],
  [Note],
  [CreationDate],
  [CreatedBy])
    VALUES (@ContractId, 'RENT PAYMENT MADE $' + CAST(@Usd AS VARCHAR(10)), @CreationDate, @CreatedBy);
  SELECT
    @@IDENTITY;
END;



GO