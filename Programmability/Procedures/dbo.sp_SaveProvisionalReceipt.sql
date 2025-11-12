SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveProvisionalReceipt]
(@ProvisionalReceiptId INT            = NULL, 
 @CompanyName          VARCHAR(30), 
 @Telephone            VARCHAR(15)    = NULL, 
 @Total                DECIMAL(18, 2), 
 @OtherFees            DECIMAL(18, 2)  = NULL, 
 @Cash                 DECIMAL(18, 2), 
 @Change               DECIMAL(18, 2) = Null,
 @CreationDate         DATETIME, 
 @AgencyId             INT, 
 @CreatedBy            INT            = NULL, 
 @CardPayment          BIT, 
 @CardPaymentFee       DECIMAL(18, 2)  = NULL, 
 @Completed            BIT, 
 @CompanyId            INT            = NULL, 
 @Account              VARCHAR(50)    = NULL, 
 @CompletedBy          INT            = NULL, 
 @CompletedOn          DATETIME       = NULL, 
 @AccountIsCheck  BIT            = NULL, 
 @TelephoneUSA			  VARCHAR(15)    = NULL,
 @TelIsCheck       BIT            = NULL, 
 @TypeOfInternationalTopUpsId int = null,
 @CountryId int = null,
 @ClientName   VARCHAR(50)    = NULL,
 @TransactionNumber  VARCHAR(50)    = NULL,
 @IdCreated      INT OUTPUT
)
AS
    BEGIN
        IF(@ProvisionalReceiptId IS NULL)
            BEGIN
                INSERT INTO [dbo].ProvisionalReceipts
                (Total, 
                 CompanyName, 
                 OtherFees, 
                 CreationDate, 
                 AgencyId, 
                 CreatedBy, 
                 CardPayment, 
                 CardPaymentFee, 
                 Cash, 
                 Change, 
                 Completed, 
                 Telephone, 
                 CompanyId, 
                 Account, 
                 AccountIsCheck,
                 TelIsCheck,
				 TelephoneUSA,
				 ClientName,				
				 TypeOfInternationalTopUpsId,
				 CountryId
                )
                VALUES
                (@Total, 
                 UPPER(@CompanyName), 
                 @OtherFees, 
                 @CreationDate, 
                 @AgencyId, 
                 @CreatedBy, 
                 @CardPayment, 
                 @CardPaymentFee, 
                 @Cash, 
                 @Change, 
                 @Completed, 
                 @Telephone, 
                 @CompanyId, 
                 @Account, 
                 @AccountIsCheck,
                 @TelIsCheck,
				 @TelephoneUSA,
				 @ClientName,				
				 @TypeOfInternationalTopUpsId,
				 @CountryId
                );

				   SET @IdCreated = @@IDENTITY;

            END;
            ELSE
            BEGIN
                UPDATE [dbo].ProvisionalReceipts
                  SET 
                      Completed = @Completed, 
                      Telephone = @Telephone, 
                      CompletedBy = @CompletedBy, 
                      CompletedOn = @CompletedOn,
					  TransactionNumber = @TransactionNumber

                WHERE ProvisionalReceiptId = @ProvisionalReceiptId;
				 SET @IdCreated = @ProvisionalReceiptId;
            END;
    END;
GO