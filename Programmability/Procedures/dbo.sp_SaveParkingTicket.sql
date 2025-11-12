SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveParkingTicket]
(@ParkingTicketId INT            = NULL,
 @Usd             DECIMAL(18, 2),
 @Fee1            DECIMAL(18, 2),
 @Fee2            DECIMAL(18, 2),
 @FeeEls            DECIMAL(18, 2),
 @CreationDate    DATETIME,
 @AgencyId        INT,
 @CreatedBy       INT,
 @IdCreated       INT OUTPUT,
 @CardPayment    BIT,
 @CardPaymentFee INT            = NULL,
  @UpdatedBy INT, 
 @UpdatedOn DATETIME
)
AS
     BEGIN
         IF(@ParkingTicketId IS NULL)
             BEGIN
                 INSERT INTO [dbo].[ParkingTickets]
                 (USD,
                  Fee1,
                  Fee2,
                  CreationDate,
                  AgencyId,
                  CreatedBy,
                  CardPayment,
                  CardPaymentFee,
			   FeeEls,
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
			   @FeeEls,
			   @UpdatedBy, 
                 @UpdatedOn
                 );
                 SET @IdCreated = @@IDENTITY;
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].[ParkingTickets]
                   SET
                       USD = @Usd,
                       Fee1 = @Fee1,
                       Fee2 = @Fee2,
                       CreationDate = @CreationDate,
                       CardPayment = @CardPayment,
                       CardPaymentFee = @CardPaymentFee,
				   FeeEls = @FeeEls,
				   UpdatedBy = @UpdatedBy, 
                      UpdatedOn = @UpdatedOn
                 WHERE ParkingTicketId = @ParkingTicketId;
                 SET @IdCreated = 0;
         END;
     END;
GO