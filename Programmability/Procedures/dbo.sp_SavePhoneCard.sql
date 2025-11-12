SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SavePhoneCard]
(@PhoneCardId   INT            = NULL, 
 @Quantity      INT, 
 @PhoneCardsUsd DECIMAL(18, 2), 
 @AgencyId      INT, 
 @CreatedBy     INT, 
 @CreationDate  DATETIME,
 @UpdatedBy                       INT = NULL, 
 @UpdatedOn                       DATETIME = NULL
)
AS
    BEGIN
        IF(@PhoneCardId IS NULL)
            BEGIN
                DECLARE @commission DECIMAL(18, 2);
                SET @commission =
                (
                    SELECT TOP 1 Percentage
                    FROM [dbo].[CommisinPhoneCardsSetting]
                );
                INSERT INTO [dbo].PhoneCards
                (PhoneCardsUsd, 
                 Quantity, 
                 AgencyId, 
                 CreatedBy, 
                 CreationDate, 
                 Commission,
				  UpdatedBy, 
                 UpdatedOn
                )
                VALUES
                (@PhoneCardsUsd, 
                 @Quantity, 
                 @AgencyId, 
                 @CreatedBy, 
                 @CreationDate, 
                 @commission,
				   @UpdatedBy, 
                 @UpdatedOn
                );
        END;
            ELSE
            BEGIN
                UPDATE [dbo].PhoneCards
                  SET 
                      PhoneCardsUsd = @PhoneCardsUsd, 
                      Quantity = @Quantity,
					   UpdatedBy = @UpdatedBy, 
                      UpdatedOn= @UpdatedOn
                WHERE PhoneCardId = @PhoneCardId;
        END;
    END;
GO