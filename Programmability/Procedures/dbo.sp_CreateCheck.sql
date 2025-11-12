SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreateCheck]
(@CheckId              INT            = NULL, 
 @ClientId             INT            = NULL, 
 @CashierId            INT, 
 @CheckTypeId          INT            = NULL, 
 @CheckFront           VARCHAR(200)   = NULL, 
 @CheckBack            VARCHAR(200)   = NULL, 
 @Maker                INT, 
 @Amount               DECIMAL(18, 2),
 --@Fee decimal(18,2),
 @Number               VARCHAR(50)    = NULL, 
 @Account              VARCHAR(50), 
 @Routing              VARCHAR(50)    = NULL, 
 @DateCheck            DATETIME       = NULL, 
 @DateCashed           DATETIME, 
 @AgencyId             INT,
 --@ValidatedBy        INT            = NULL,
 @ValidatedCheckDateBy INT            = NULL, 
 @ValidateCheckTypeBy  INT            = NULL,
 @LastUpdatedBy        INT            = NULL, 
 @ValidatedRangeBy     INT            = NULL, 
 @ValidatedRoutingBy   INT            = NULL, 
 @LastUpdatedOn        DATETIME       = NULL, 
 @ValidatedMaxAmountBy INT            = NULL, 
 @ValidatedPhoneBy     INT            = NULL, 
 @CheckStatusCode      VARCHAR(10)    = NULL,
  @ValidatedPostdatedChecksBy INT            = NULL,
    @ValidatedRoutingByRightCashier INT            = NULL
)
AS
    BEGIN
        DECLARE @CheckStatusId INT= NULL;
        SET @CheckStatusId =
        (
            SELECT DocumentStatusId
            FROM DocumentStatus
            WHERE Code = @CheckStatusCode
        );

        --Se valida que el cheuqe no tenga ningún tipo de bloqueo
        IF EXISTS
        (
            SELECT ReturnedCheckId
            FROM returnedcheck
            WHERE ClientId = @ClientId
                  AND ClientBlocked = 1
                  AND @ClientId IS NOT NULL
        )
            BEGIN
                SELECT-1;--Client blocked
            END;
            ELSE
            IF EXISTS
            (
                SELECT ReturnedCheckId
                FROM returnedcheck
                WHERE MakerId = @Maker
                      AND MakerBlocked = 1
            )
                BEGIN
                    SELECT-2;--Maker blocked
                END;
                ELSE
                IF EXISTS
                (
                    SELECT ReturnedCheckId
                    FROM returnedcheck
                    WHERE Account = @Account
                          AND AccountBlocked = 1
                )
                    BEGIN
                        SELECT-3; --/Account blocked
                    END;
        IF EXISTS
        (
            SELECT TOP 1 1
            FROM [Checks]
            WHERE Account = @Account
                  AND Number = @Number
                  AND (CheckId <> @CheckId
                       OR @CheckId IS NULL)
        )
            BEGIN 
                SELECT-4; --Check and account duplicated
            END;
            ELSE
            IF(@CheckId IS NULL)
                BEGIN
                    BEGIN
                        INSERT INTO [dbo].[Checks]
                        ([ClientId], 
                         [CashierId], 
                         [CheckTypeId], 
                         [CheckFront], 
                         [CheckBack], 
                         [DateCashed], 
                         [Maker], 
                         [Amount], 
                         [Fee], 
                         [Number], 
                         [Account], 
                         [Routing], 
                         [DateCheck], 
                         [AgencyId],
                         --[ValidatedBy],
                         ValidatedCheckDateBy,
                         ValidateCheckTypeBy, 
                         LastUpdatedBy, 
                         LastUpdatedOn, 
                         ValidatedRangeBy, 
                         ValidatedRoutingBy, 
                         ValidatedMaxAmountBy, 
                         ValidatedPhoneBy, 
                         CheckStatusId,
						 ValidatedPostdatedChecksBy,
             ValidatedRoutingByRightCashier
                        )
                        VALUES
                        (@ClientId, 
                         @CashierId, 
                         @CheckTypeId, 
                         @CheckFront, 
                         @CheckBack, 
                         @DateCashed, 
                         @Maker, 
                         @Amount, 
                         0, 
                         @Number, 
                         @Account, 
                         @Routing, 
                         @DateCheck, 
                         @AgencyId,
                         --@ValidatedBy,
                         @ValidatedCheckDateBy, 
                         @ValidateCheckTypeBy,
                         @LastUpdatedBy, 
                         @LastUpdatedOn, 
                         @ValidatedRangeBy, 
                         @ValidatedRoutingBy, 
                         @ValidatedMaxAmountBy, 
                         @ValidatedPhoneBy, 
                         @CheckStatusId,
						 @ValidatedPostdatedChecksBy,
             @ValidatedRoutingByRightCashier
                        );
                        SELECT @@IDENTITY;
                    END;
                END;
                ELSE
                BEGIN
                    UPDATE [dbo].[Checks]
                      SET 
                          [ClientId] = @ClientId, 
                          [CheckTypeId] = @CheckTypeId, 
                          [AgencyId] = @AgencyId, 
                          [CheckFront] = @CheckFront, 
                          [CheckBack] = @CheckBack, 
                          [Maker] = @Maker, 
                          [Account] = @Account, 
                          [Routing] = @Routing, 
                          [DateCheck] = @DateCheck, --Se agrega este campo en la tare 4910
                          Number = @Number, 
                          LastUpdatedBy = @LastUpdatedBy, 
                          LastUpdatedOn = @LastUpdatedOn, 
                          Amount = @Amount, 
                          ValidatedRoutingBy = @ValidatedRoutingBy, 
                          ValidatedMaxAmountBy = @ValidatedMaxAmountBy, 
                          ValidatedCheckDateBy = @ValidatedCheckDateBy, 
                          ValidateCheckTypeBy = @ValidateCheckTypeBy,
                          ValidatedPhoneBy = @ValidatedPhoneBy, 
                          CheckStatusId = @CheckStatusId,
						  ValidatedPostdatedChecksBy = @ValidatedPostdatedChecksBy
                    WHERE CheckId = @CheckId;
                    SELECT @CheckId;
                END;
    END;
GO