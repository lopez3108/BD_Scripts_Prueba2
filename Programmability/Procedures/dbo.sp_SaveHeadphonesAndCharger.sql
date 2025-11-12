SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveHeadphonesAndCharger]
(@HeadphonesAndChargerId INT            = NULL, 
 @HeadphonesQuantity     INT, 
 @ChargersQuantity       INT, 
 @HeadphonesUsd          DECIMAL(18, 2), 
 @ChargersUsd            DECIMAL(18, 2), 
 @AgencyId               INT, 
 @CreatedBy              INT, 
 @CreationDate           DATETIME,
 @UpdatedBy              INT = NULL, 
 @UpdatedOn              DATETIME = NULL,
 @CardPayment			 BIT,
 @CardPaymentFee		 DECIMAL(18, 2)
)
AS
    BEGIN
        DECLARE @headPhonesCost DECIMAL(18, 2);
        SET @headPhonesCost = 0;
        DECLARE @chargersCost DECIMAL(18, 2);
        SET @chargersCost = 0;
        IF(@HeadphonesQuantity > 0)
            BEGIN
                SET @headPhonesCost =
                (
                    SELECT TOP 1 ISNULL(Headphones, 0)
                    FROM [dbo].ComissionHeadphonesAndChargersSettings
                );
        END;
        IF(@ChargersQuantity > 0)
            BEGIN
                SET @chargersCost =
                (
                    SELECT TOP 1 ISNULL(Chargers, 0)
                    FROM [dbo].ComissionHeadphonesAndChargersSettings
                );
        END;
        IF(@HeadphonesAndChargerId IS NULL)
            BEGIN
                INSERT INTO [dbo].HeadphonesAndChargers
                (HeadphonesUsd, 
                 ChargersUsd, 
                 HeadphonesQuantity, 
                 ChargersQuantity, 
                 AgencyId, 
                 CreatedBy, 
                 CreationDate, 
                 CostHeadPhones, 
                 CostChargers,
				 UpdatedBy, 
                 UpdatedOn,
				  CardPayment,
				 CardPaymentFee
                )
                VALUES
                (@HeadphonesUsd, 
                 @ChargersUsd, 
                 @HeadphonesQuantity, 
                 @ChargersQuantity, 
                 @AgencyId, 
                 @CreatedBy, 
                 @CreationDate, 
                 @headPhonesCost, 
                 @chargersCost,
				  @UpdatedBy, 
                 @UpdatedOn,
				 @CardPayment,
				 @CardPaymentFee
				
                );
        END;
            ELSE
            BEGIN
                UPDATE [dbo].HeadphonesAndChargers
                  SET 
                      HeadphonesUsd = @HeadphonesUsd, 
                      ChargersUsd = @ChargersUsd, 
                      HeadphonesQuantity = @HeadphonesQuantity, 
                       ChargersQuantity = @ChargersQuantity,
					   UpdatedBy = @UpdatedBy, 
                       UpdatedOn= @UpdatedOn,
					   CardPayment = @CardPayment,
					   CardPaymentFee = @CardPaymentFee
                WHERE HeadphonesAndChargerId = @HeadphonesAndChargerId;
        END;
    END;
	select * from HeadphonesAndChargers
	select * from OthersDetails
GO