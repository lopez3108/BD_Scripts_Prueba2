SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Nombre:  sp_SaveCheckEls				    															         
-- Descripcion: Procedimiento Almacenado que guarda los ChecksEls.				    					         
-- Creado por: 																		 
-- Fecha: 																								 	
-- Modificado por: Diego León Acevedo Arenas																										 
-- Fecha: 2023-08-04																											 
-- Observación:  Guardamos campo ValidateCheckFraudAccountBy, ValidateCheckFraudCheckNumberBy, ValidateCheckFraudAccountRoutingBy, ValidateCheckFraudClientBy, ValidateCheckFraudMakerBy.
-- Test: EXECUTE [dbo].[sp_SaveCheckEls]                                    
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[sp_SaveCheckEls]
(@CheckElsId           INT            = NULL,
@CheckId           INT            = NULL,
 @ProviderTypeId       INT,
 @Amount               DECIMAL(18, 2),
 @Fee                  DECIMAL(18, 2),
 @CreationDate         DATETIME = NULL,
 @CreatedBy            INT = NULL,
 @AgencyId             INT,
 @CheckDate            DATETIME,
 --@ValidatedOn          DATETIME       = NULL,
 --@ValidatedBy          INT            = NULL,
 @FromRegisterApp      BIT            = NULL,
 @ClientId             INT            = NULL,
 @CheckNumber          VARCHAR(30)    = NULL,
 @Account              VARCHAR(30)    = NULL,
 @Routing              VARCHAR(30)    = NULL,
 @MakerId              INT            = NULL,
 @ValidatedRoutingBy   INT            = NULL,
 @ValidatedRangeBy     INT            = NULL,
 @ValidatedMaxAmountBy INT            = NULL,
 @ValidatedCheckDateBy INT            = NULL,
 @ValidatedPostdatedChecksBy INT            = NULL,
 @LastUpdatedBy        INT            = NULL, 
 @LastUpdatedOn        DATETIME       = NULL,
 @CheckClientIdGuidGroup             VARCHAR(100)    = NULL,
 @IsCheckParent      BIT            = NULL,
 @ClientTelephone             VARCHAR(20)    = NULL,
 @IdCreated            INT OUTPUT,
 @ValidateCheckFraudAccountBy INT = NULL,
 @ValidateCheckFraudCheckNumberBy INT = NULL,
 @ValidateCheckFraudClientBy INT = NULL,
 @ValidateCheckFraudClientTelephoneBy INT = NULL,
 @ValidateCheckFraudAddressBy INT = NULL,
 @ValidateCheckFraudIdentificacionNumberBy INT = NULL,
 @ValidateCheckFraudMakerBy INT = NULL,
  @ValidateCheckFraudFileNumberBy INT = NULL,
 @ValidateCheckFraudAccountSafeBy INT = NULL,
 @ValidateCheckClientTelBy INT = NULL
)
AS
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
                SET @IdCreated =-1;--Client blocked
            END;
            ELSE
            IF EXISTS
            (
                SELECT ReturnedCheckId
                FROM returnedcheck
                WHERE MakerId = @MakerId
                      AND MakerBlocked = 1
            )
                BEGIN
                    SET @IdCreated =-2;--Maker blocked
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
                        SET @IdCreated =-3; --/Account blocked
                    END;
					ELSE
        IF EXISTS
        (
            SELECT TOP 1 1
            FROM [ChecksEls]
            WHERE Account = @Account
                  AND CheckNumber = @CheckNumber
                  AND (CheckElsId <> @CheckElsId
                       OR @CheckElsId IS NULL)
        )
            BEGIN 
                SET @IdCreated =-4; --Check and account duplicated
            END;
            ELSE

  
         IF(@CheckElsId IS NULL)

             BEGIN
                 INSERT INTO [dbo].ChecksEls
                 (ProviderTypeId,
                  Amount,
                  CreationDate,
                  CreatedBy,
                  AgencyId,
                  --ValidatedOn,
                  --ValidatedBy,
                  Fee,
                  CheckDate,
                  FromRegisterApp,
                  ClientId,
                  CheckNumber,
                  Account,
                  Routing,
                  MakerId,
                  ValidatedRoutingBy,
                  ValidatedRangeBy,
                  ValidatedMaxAmountBy,
				  ValidatedCheckDateBy,
				  ValidatedPostdatedChecksBy,
				  CheckId,
				  LastUpdatedBy, 
                 LastUpdatedOn,
				 CheckClientIdGuidGroup,
				 IsCheckParent,
				 ClientTelephone,
				 ValidateCheckFraudAccountBy,
				 ValidateCheckFraudCheckNumberBy,
				 --ValidateCheckFraudAccountRoutingBy,
				 ValidateCheckFraudClientBy,
				 ValidateCheckFraudClientTelephoneBy,
				 ValidateCheckFraudAddressBy,
				 ValidateCheckFraudIdentificacionNumberBy,
				 ValidateCheckFraudMakerBy,
				 ValidateCheckFraudFileNumberBy,
				 ValidateCheckFraudAccountSafeBy,
         ValidateCheckClientTelBy
                 )
                 VALUES
                 (@ProviderTypeId,
                  @Amount,
                  @CreationDate,
                  @CreatedBy,
                  @AgencyId,
                  --@ValidatedOn,
                  --@ValidatedBy,
                  @Fee,
                  @CheckDate,
                  @FromRegisterApp,
                  @ClientId,
                  @CheckNumber,
                  @Account,
                  @Routing,
                  @MakerId,
                  @ValidatedRoutingBy,
                  @ValidatedRangeBy,
                  @ValidatedMaxAmountBy,
				  @ValidatedCheckDateBy,
				  @ValidatedPostdatedChecksBy,
				  @CheckId,
				  @LastUpdatedBy, 
                 @LastUpdatedOn,
				 @CheckClientIdGuidGroup,
				 @IsCheckParent,
				 CASE WHEN @CheckId IS NOT NULL --El telefono solo lo agregamos cuando el cheque no tiene cliente
				 THEN NULL
				 ELSE
				 @ClientTelephone
				 END,
				 @ValidateCheckFraudAccountBy,
				 @ValidateCheckFraudCheckNumberBy,
				 --@ValidateCheckFraudAccountRoutingBy,
				 @ValidateCheckFraudClientBy,
				 @ValidateCheckFraudClientTelephoneBy,
				 @ValidateCheckFraudAddressBy,
				 @ValidateCheckFraudIdentificacionNumberBy,
				 @ValidateCheckFraudMakerBy,
				 @ValidateCheckFraudFileNumberBy,
				 @ValidateCheckFraudAccountSafeBy,
         @ValidateCheckClientTelBy
                 );
                 SET @IdCreated = @@IDENTITY;
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].ChecksEls
                   SET
					   ProviderTypeId = @ProviderTypeId,
                       Amount = @Amount,
                       --ValidatedOn = @ValidatedOn,
                       --ValidatedBy = @ValidatedBy,
                       CheckDate = @CheckDate,
                       FromRegisterApp = @FromRegisterApp,
                       ClientId = @ClientId,
                       CheckNumber = @CheckNumber,
                       Account = @Account,
                       Routing = @Routing,
                       MakerId = @MakerId,
                       ValidatedRoutingBy = @ValidatedRoutingBy,
                       ValidatedRangeBy = @ValidatedRangeBy,
                       ValidatedMaxAmountBy = @ValidatedMaxAmountBy,
					   ValidatedCheckDateBy = @ValidatedCheckDateBy,
					   ValidatedPostdatedChecksBy = @ValidatedPostdatedChecksBy,
					   LastUpdatedBy  = @LastUpdatedBy, 
					   LastUpdatedOn   = @LastUpdatedOn,
					   ClientTelephone = 	 CASE WHEN @CheckId IS NOT NULL --El telefono solo lo agregamos cuando el cheque no tiene cliente
													 THEN NULL
													 ELSE
													 @ClientTelephone
													 END,
					   ValidateCheckFraudAccountBy = @ValidateCheckFraudAccountBy,
					   ValidateCheckFraudCheckNumberBy = @ValidateCheckFraudCheckNumberBy,
					   --ValidateCheckFraudAccountRoutingBy = @ValidateCheckFraudAccountRoutingBy,
					   ValidateCheckFraudClientBy = @ValidateCheckFraudClientBy,
					   ValidateCheckFraudClientTelephoneBy = @ValidateCheckFraudClientTelephoneBy,
					   ValidateCheckFraudAddressBy = @ValidateCheckFraudAddressBy,
					   ValidateCheckFraudIdentificacionNumberBy = @ValidateCheckFraudIdentificacionNumberBy,
					   ValidateCheckFraudMakerBy = @ValidateCheckFraudMakerBy,
					   ValidateCheckFraudFileNumberBy = @ValidateCheckFraudFileNumberBy,
					   ValidateCheckFraudAccountSafeBy  = @ValidateCheckFraudAccountSafeBy,
             ValidateCheckClientTelBy = @ValidateCheckClientTelBy
                 WHERE CheckElsId = @CheckElsId;
                 SET @IdCreated = @CheckElsId;
         END;


GO