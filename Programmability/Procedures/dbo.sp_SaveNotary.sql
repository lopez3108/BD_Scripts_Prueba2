SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveNotary]
(@NotaryId     INT            = NULL, 
 @Quantity     INT, 
 @Usd          DECIMAL(18, 2), 
 @AgencyId     INT, 
 @CreatedBy    INT, 
 @CreationDate DATETIME, 
 @UpdatedBy    INT            = NULL, 
 @UpdatedOn    DATETIME       = NULL, 
  @ValidatedBy    INT            = NULL, 
 @ValidatedOn    DATETIME       = NULL,
 @IdCreated    INT OUTPUT
)
AS
    BEGIN
        IF(@NotaryId IS NULL)
            BEGIN
                INSERT INTO [dbo].[Notary]
                (Quantity, 
                 Usd, 
                 AgencyId, 
                 CreatedBy, 
                 CreationDate,
				  UpdatedBy, 
                 UpdatedOn
                )
                VALUES
                (@Quantity, 
                 @Usd, 
                 @AgencyId, 
                 @CreatedBy, 
                 @CreationDate,
				 @UpdatedBy, 
                 @UpdatedOn
                );
                SET @IdCreated = @@IDENTITY;
        END;
            ELSE
            BEGIN
                UPDATE [dbo].[Notary]
                  SET 
                      Quantity = @Quantity, 
                      Usd = @Usd, 
                      UpdatedOn = @UpdatedOn, 
                      UpdatedBy = @UpdatedBy,
					   ValidatedBy = @ValidatedBy, 
                      ValidatedOn = @ValidatedOn
                WHERE NotaryId = @NotaryId;
                SET @IdCreated = 0;
        END;
    END;
GO