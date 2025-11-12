SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreatePaymentBank] @BankAccountId INT            = NULL, 
                                             @USD           DECIMAL(18, 2), 
                                             @CreatedBy     INT, 
                                             @CreationDate  DATETIME, 
                                             @Date          DATETIME = NULL, 
                                             @FileImageName VARCHAR(1000)  = NULL, 
                                             @Status        INT, 
                                             @PaymentBankId INT            = NULL, 
											 @AgencyId INT            = NULL, 
											 @IsDebitCredit    bit = null, 
                                             @IdCreated     INT OUTPUT
AS
    BEGIN
        IF(@PaymentBankId IS NULL)
            BEGIN
                INSERT INTO [dbo].[PaymentBanks]
                ([BankAccountId], 
                 [Date], 
                 [USD], 
                 [CreationDate], 
                 [CreatedBy], 
                 FileImageName, 
                 STATUS,
				 AgencyId,
				 IsDebitCredit
                )
                VALUES
                (@BankAccountId, 
                 @Date, 
                 @USD, 
                 @CreationDate, 
                 @CreatedBy, 
                 @FileImageName, 
                 @Status,
				 @AgencyId,
				 @IsDebitCredit
				 
                );
                SELECT @IdCreated = @@IDENTITY;
        END;
            ELSE
            BEGIN
                UPDATE [dbo].[PaymentBanks]
                  SET 
                      [BankAccountId] = @BankAccountId, 
                     
                      STATUS = @Status, 
                      USD = @USD, 
                      Date = @Date, 
                      CreatedBy = @CreatedBy, 
                      FileImageName = @FileImageName
                WHERE PaymentBankId = @PaymentBankId;
                SET @IdCreated = @PaymentBankId;
        END;
    END;
GO