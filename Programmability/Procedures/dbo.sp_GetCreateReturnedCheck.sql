SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetCreateReturnedCheck] @ReturnedCheckId  INT            = NULL, 
                                                  @ReturnDate       DATETIME       = NULL, 
                                                  @ProviderId       INT            = NULL, 
                                                  @BelongAgencyId   INT            = NULL, 
                                                  @ReturnedAgencyId INT            = NULL, 
                                                  @CheckDate        DATETIME       = NULL, 
                                                  @ClientId         INT            = NULL, 
                                                  @MakerId          INT            = NULL, 
                                                  @CheckNumber      VARCHAR(15)    = NULL, 
                                                  @Usd              DECIMAL(18, 2)  = NULL, 
                                                  @Fee              DECIMAL(18, 2)  = NULL, 
                                                  @ProviderFee      DECIMAL(18, 2)  = NULL, 
                                                  @ReturnReasonId   INT            = NULL, 
                                                  @CreationDate     DATETIME       = NULL, 
                                                  @CreatedBy        INT            = NULL, 
                                                  @LastModifiedDate DATETIME       = NULL, 
                                                  @LastModifiedBy   INT            = NULL, 
                                                  @ClientAddress    VARCHAR(70)    = NULL, 
                                                  @MakerAddress     VARCHAR(70)    = NULL, 
                                                  @BankAddress      VARCHAR(70)    = NULL, 
                                                  @Account          VARCHAR(50)    = NULL, 
                                                  @Routing          VARCHAR(50)    = NULL, 
                                                  @ClientBlocked    BIT            = NULL, 
                                                  @MakerBlocked     BIT            = NULL, 
                                                  @AccountBlocked   BIT            = NULL, 
                                                  @AdminAgencyId    INT            = NULL, 
                                                        @LawyerFee     BIT            = NULL, 
                                                  @CourtFee   BIT            = NULL, 
                                                  @StatusId         INT            = NULL
AS
    BEGIN
        IF(@ReturnedCheckId IS NULL)
            BEGIN
                DECLARE @ClientAddressId INT, @MakerAddressId INT, @BankAddressId INT;
                SET @ClientAddressId =
                (
                    SELECT TOP 1 AddressXClientId
                    FROM AddressXClient
                    WHERE ClientId = @ClientId
                          AND Address = @ClientAddress
                );
                SET @MakerAddressId =
                (
                    SELECT TOP 1 AddressXMakerId
                    FROM AddressXMaker
                    WHERE MakerId = @MakerId
                          AND Address = @MakerAddress
                );
                --SET @BankAddressId =
                --(
                --    SELECT *
                --    FROM AddressXBank
                --    WHERE BankId = @BankId
                --          AND Address = @BankAddress
                --);
                INSERT INTO [dbo].[ReturnedCheck]
                ([ReturnDate], 
                 [ProviderId], 
                 [BelongAgencyId], 
                 [ReturnedAgencyId], 
                 [CheckDate], 
                 [MakerId], 
                 [CheckNumber], 
                 [USD], 
                 [Fee], 
                 ProviderFee, 
                 [ReturnReasonId], 
                 [StatusId], 
                 [CreationDate], 
                 [CreatedBy], 
                 [LastModifiedDate], 
                 [LastModifiedBy], 
                 [ClientId],
                 --[AddressXBankId],
                 [AddressXMakerId], 
                 [AddressXClientId], 
                 Account, 
                 Routing, 
                 ClientBlocked, 
                 MakerBlocked, 
                 AccountBlocked, 
                 AdminAgencyId
                )
                VALUES
                (@ReturnDate, 
                 @ProviderId, 
                 @BelongAgencyId, 
                 @ReturnedAgencyId, 
                 @CheckDate, 
                 @MakerId, 
                 @CheckNumber, 
                 @Usd, 
                 @Fee, 
                 @ProviderFee, 
                 @ReturnReasonId, 
                (
                    SELECT TOP 1 ReturnStatusId
                    FROM ReturnStatus
                    WHERE Code = 'C01'
                ), 
                 @CreationDate, 
                 @CreatedBy, 
                 @LastModifiedDate, 
                 @LastModifiedBy, 
                 @ClientId,
                 --@BankAddressId,
                 @MakerAddressId, 
                 @ClientAddressId, 
                 @Account, 
                 @Routing, 
                 @ClientBlocked, 
                 @MakerBlocked, 
                 @AccountBlocked, 
                 @AdminAgencyId
                );
                SELECT @@IDENTITY;
            END;
            ELSE
            BEGIN
                UPDATE [dbo].[ReturnedCheck]
                  SET 
                      ClientBlocked = @ClientBlocked, 
                      MakerBlocked = @MakerBlocked, 
                      AccountBlocked = @AccountBlocked, 
                      LastModifiedDate = @LastModifiedDate, 
                      LastModifiedBy = @LastModifiedBy, 
                      StatusId = @StatusId,
LawyerFee = @LawyerFee,
CourtFee = @CourtFee,
ReturnDate = @ReturnDate,
CheckDate = @CheckDate,
ReturnedAgencyId = @ReturnedAgencyId,
BelongAgencyId = @BelongAgencyId,
ClientId = @ClientId,
MakerId = @MakerId,
ReturnReasonId = @ReturnReasonId,
                 USD = @Usd,
                 Fee = @Fee,
                 ProviderFee = @ProviderFee


                WHERE ReturnedCheckId = @ReturnedCheckId;
                SELECT @ReturnedCheckId;
            END;
    END;



GO