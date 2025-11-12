SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveFinancing]
(@FinancingId         INT            = NULL,
 @Name                VARCHAR(50)    = NULL,
 @FinancingStatusId   INT            = NULL,
 @FinancingStatusCode VARCHAR(10)    = NULL,
 @Trp                 VARCHAR(10)    = NULL,
 @Telephone           VARCHAR(12)    = NULL,
 @Usd                 DECIMAL(18, 2)  = NULL,
 @CancellarionFee     DECIMAL(18, 2)  = NULL,
 @CancellationUsd     DECIMAL(18, 2)  = NULL,
 @Note                VARCHAR(200)   = NULL,
 @AgencyId            INT            = NULL,
 @CreatedBy           INT            = NULL,
 @CreatedOn           DATETIME       = NULL,
 @CompletedBy         INT            = NULL,
 @CompletedOn         DATETIME       = NULL,
 @ExpirationDate      DATETIME       = NULL,
 @CanceledBy          INT            = NULL,
 @CanceledOn          DATETIME       = NULL,
 @Dealer              BIT            = NULL,
 @DealerName          VARCHAR(50)    = NULL,
 @DealerNumber        VARCHAR(10)    = NULL,
 @DealerAddress       VARCHAR(40)    = NULL,
 @IdCreated           INT OUTPUT
)
AS
     BEGIN
         SET @FinancingStatusId =
         (
             SELECT FinancingStatusId
             FROM FinancingStatus
             WHERE Code = @FinancingStatusCode
         );
         IF(@FinancingId IS NULL)
             BEGIN
                 INSERT INTO [dbo].Financing
                 (Name,
                  FinancingStatusId,
                  Trp,
                  Telephone,
                  Usd,
                  Note,
                  CreatedBy,
                  CreatedOn,
                  AgencyId,
                  Dealer,
                  DealerName,
                  DealerNumber,
                  DealerAddress,
                  ExpirationDate,
                  CancellarionFee,
                  CancellationUsd
                 )
                 VALUES
                 (@Name,
                  @FinancingStatusId,
                  @Trp,
                  @Telephone,
                  @Usd,
                  @Note,
                  @CreatedBy,
                  @CreatedOn,
                  @AgencyId,
                  @Dealer,
                  @DealerName,
                  @DealerNumber,
                  @DealerAddress,
                  @ExpirationDate,
                  @CancellarionFee,
                  @CancellationUsd
                 );
                 SET @IdCreated = @@IDENTITY;
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].Financing
                   SET
                       Name = @Name,
                       FinancingStatusId = @FinancingStatusId,
                       Trp = @Trp,
                       Telephone = @Telephone,
                       Usd = @Usd,
                       Note = @Note,
                       CompletedBy = @CompletedBy,
                       CompletedOn = @CompletedOn,
                       CanceledBy = @CanceledBy,
                       CanceledOn = @CanceledOn,
                       Dealer = @Dealer,
                       DealerName = @DealerName,
                       DealerNumber = @DealerNumber,
                       DealerAddress = @DealerAddress,
                       ExpirationDate = @ExpirationDate,
                       CancellarionFee = @CancellarionFee,
                       CancellationUsd = @CancellationUsd
                 WHERE FinancingId = @FinancingId;
                 SET @IdCreated = @FinancingId;
         END;
     END;
GO