SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveParkingTicketCard]
(@ParkingTicketCardId    INT            = NULL, 
 @Usd                    DECIMAL(18, 2), 
 @Fee1                   DECIMAL(18, 2), 
 @Fee2                   DECIMAL(18, 2), 
 @CreationDate           DATETIME, 
 @AgencyId               INT, 
 @IdCreated              INT OUTPUT, 
 @CreatedBy              INT            = NULL, 
 @CardPayment            BIT, 
 @CardPaymentFee         INT            = NULL, 
 @TicketsPaymentTypeCode VARCHAR(10)    = NULL, 
 @MoneyOrderNumber       VARCHAR(20)    = NULL, 
 @CardBankId             INT            = NULL, 
 @BankAccountId          INT            = NULL, 
 @MoneyOrderFee          DECIMAL(18, 2)  = NULL, 
 @FileIdName             VARCHAR(1000)  = NULL, 
 @UpdatedBy              INT, 
 @UpdatedOn              DATETIME
)
AS
    BEGIN
        DECLARE @TicketPaymentTypeId INT;
        SET @TicketPaymentTypeId =
        (
            SELECT TOP 1 TicketPaymentTypeId
            FROM [dbo].TicketPaymentTypes
            WHERE Code = @TicketsPaymentTypeCode
        );
        DECLARE @MoneyOrderFeeIn DECIMAL(18, 2)= NULL;
        IF(@TicketsPaymentTypeCode = 'C01'
           AND @MoneyOrderFee IS NOT NULL)
            BEGIN
                SET @MoneyOrderFeeIn = @MoneyOrderFee;
                SET @CardBankId = NULL;
                SET @BankAccountId = NULL;
            END;
            ELSE
            IF(@TicketsPaymentTypeCode = 'C01')
                BEGIN
                    SET @MoneyOrderFeeIn =
                    (
                        SELECT TOP 1 MoneyOrderFee
                        FROM [dbo].[ConfigurationELS]
                    );
                    SET @CardBankId = NULL;
                    SET @BankAccountId = NULL;
                END;
        IF(@TicketsPaymentTypeCode = 'C02')
            BEGIN
                SET @MoneyOrderNumber = NULL;
                SET @MoneyOrderFee = NULL;
                SET @BankAccountId = NULL;
            END;
        IF(@TicketsPaymentTypeCode = 'C03')
            BEGIN
                SET @MoneyOrderNumber = NULL;
                SET @MoneyOrderFee = NULL;
                SET @CardBankId = NULL;
            END;
        IF(@ParkingTicketCardId IS NULL)
            BEGIN
                INSERT INTO [dbo].[ParkingTicketsCards]
                (USD, 
                 Fee1, 
                 Fee2, 
                 CreationDate, 
                 AgencyId, 
                 CreatedBy, 
                 CardPayment, 
                 CardPaymentFee, 
                 MoneyOrderFee, 
                 MoneyOrderNumber, 
                 CardBankId, 
                 BankAccountId, 
                 TicketPaymentTypeId, 
                 FileIdName, 
                 UpdatedBy, 
                 UpdatedOn
                )
                VALUES
                (@Usd, 
                 @Fee1, 
                 @Fee2, 
                 @CreationDate, 
                 @AgencyId, 
                 @CreatedBy, 
                 @CardPayment, 
                 @CardPaymentFee, 
                 @MoneyOrderFeeIn, 
                 @MoneyOrderNumber, 
                 @CardBankId, 
                 @BankAccountId, 
                 @TicketPaymentTypeId, 
                 @FileIdName, 
                 @UpdatedBy, 
                 @UpdatedOn
                );
                SET @IdCreated = @@IDENTITY;
            END;
            ELSE
            BEGIN
                UPDATE [dbo].[ParkingTicketsCards]
                  SET 
                      USD = @Usd, 
                      Fee1 = @Fee1, 
                      Fee2 = @Fee2, 
                      CreationDate = @CreationDate, 
                      CardPayment = @CardPayment, 
                      CardPaymentFee = @CardPaymentFee, 
                      MoneyOrderFee = @MoneyOrderFeeIn, 
                      MoneyOrderNumber = @MoneyOrderNumber, 
                      CardBankId = @CardBankId, 
                      BankAccountId = @BankAccountId, 
                      TicketPaymentTypeId = @TicketPaymentTypeId, 
                      FileIdName = @FileIdName, 
                      UpdatedBy = @UpdatedBy, 
                      UpdatedOn = @UpdatedOn
                WHERE ParkingTicketCardId = @ParkingTicketCardId;
                SET @IdCreated = 0;
            END;
    END;
GO