SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-06-18 DJ/6589: Requerir ACH date para RENT PAYMENT y DEPOSIT MANAGEMENT

CREATE PROCEDURE [dbo].[sp_DepositFinancingPayment]
(@ContractId     INT,
 @Usd            DECIMAL(18, 2),
  @Cash           DECIMAL(18, 2),
 @CreationDate   DATETIME,
 @CreatedBy      INT,
 @AgencyId       INT = NULL,
 @CardPayment    BIT,
 @CardPaymentFee DECIMAL(18, 2)            = NULL,
 @BankAccountId INT = null,
 @AchDate DATETIME = NULL
)
AS
     BEGIN
         INSERT INTO [dbo].[DepositFinancingPayments]
         ([ContractId],
          [Usd],
          [CreationDate],
          [CreatedBy],
          [AgencyId],
          CardPayment,
          CardPaymentFee,
		  Cash, BankAccountId,
		  AchDate
         )
         VALUES
         (@ContractId,
          @Usd,
          @CreationDate,
          @CreatedBy,
          @AgencyId,
          @CardPayment,
          @CardPaymentFee,
		  @Cash, @BankAccountId,
		  @AchDate
         );
         INSERT INTO [dbo].[ContractNotes]
         ([ContractId],
          [Note],
          [CreationDate],
          [CreatedBy]
		
         )
         VALUES
         (@ContractId,
          'DEPOSIT PAYMENT MADE $'+CAST(@Usd AS VARCHAR(12)),
          @CreationDate,
          @CreatedBy
         );
         SELECT @@IDENTITY;
     END;

GO