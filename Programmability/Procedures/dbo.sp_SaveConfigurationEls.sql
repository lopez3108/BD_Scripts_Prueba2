SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_SaveConfigurationEls]
(@ConfigurationELSId    INT            = NULL, 
 @MoneyOrderFee         DECIMAL(18, 2), 
 @PhoneMaxDiscount      DECIMAL(18, 2), 
 @TitlePlatesDiscount   DECIMAL(18, 2), 
 @cityStickerDiscount   DECIMAL(18, 2),
 @registrationRenewalDiscount   DECIMAL(18, 2),
 @FinancingCancelFee    DECIMAL(18, 2), 
 @DaysToCashCheck       DECIMAL(18, 2), 
 @SalesTax              DECIMAL(18, 2), 
 @LaminationFee         DECIMAL(18, 2), 
 @MissingDaily          DECIMAL(18, 2), 
 @CheckRangeRegistering INT, 
 @PhotoRequired         BIT            = 0, 
 @FingerRequired        BIT            = 0,
 @ClientFingerPrintConfigurationTypeId    INT,
 @DaysTrust INT = NULL,
 @PostdatedChecks INT = NULL,
 @ExitTimeExceded INT = NULL,
 @InsuranceRegistrationReleaseFee DECIMAL(18,2)
)
AS
    BEGIN
        IF(@ConfigurationELSId IS NULL)
            BEGIN
                INSERT INTO [dbo].[ConfigurationEls]
                (MoneyOrderFee, 
                 PhoneMaxDiscount, 
                 TitlePlatesDiscount, 
                 cityStickerDiscount, 
                 registrationRenewalDiscount, 
                 FinancingCancelFee, 
                 DaysToCashCheck, 
                 SalesTax, 
                 CheckRangeRegistering, 
                 LaminationFee, 
                 MissingDaily, 
                 PhotoRequired, 
                 FingerRequired,
				 ClientFingerPrintConfigurationTypeId,
         DaysTrust,
         PostdatedChecks,
         ExitTimeExceded,
		 InsuranceRegistrationReleaseFee
                )
                VALUES
                (@MoneyOrderFee, 
                 @PhoneMaxDiscount, 
                 @TitlePlatesDiscount,
                 @cityStickerDiscount,
                 @registrationRenewalDiscount,
                 @FinancingCancelFee, 
                 @DaysToCashCheck, 
                 @SalesTax, 
                 @CheckRangeRegistering, 
                 @LaminationFee, 
                 @MissingDaily, 
                 @PhotoRequired, 
                 @FingerRequired,
        				 @ClientFingerPrintConfigurationTypeId,
                 @DaysTrust,
                 @PostdatedChecks,
                 @ExitTimeExceded,
				 @InsuranceRegistrationReleaseFee
                );
            END;
            ELSE
            BEGIN
                UPDATE [dbo].[ConfigurationEls]
                  SET 
                      MoneyOrderFee = @MoneyOrderFee, 
                      PhoneMaxDiscount = @PhoneMaxDiscount, 
                      TitlePlatesDiscount = @TitlePlatesDiscount, 
                      cityStickerDiscount = @cityStickerDiscount,
                      registrationRenewalDiscount = @registrationRenewalDiscount,
                      FinancingCancelFee = @FinancingCancelFee, 
                      DaysToCashCheck = @DaysToCashCheck, 
                      SalesTax = @SalesTax, 
                      CheckRangeRegistering = @CheckRangeRegistering, 
                      LaminationFee = @LaminationFee, 
                      MissingDaily = @MissingDaily, 
                      PhotoRequired = @PhotoRequired, 
                      FingerRequired = @FingerRequired,
          					  ClientFingerPrintConfigurationTypeId = @ClientFingerPrintConfigurationTypeId,
                      DaysTrust = @DaysTrust,
                      PostdatedChecks = @PostdatedChecks,
                      ExitTimeExceded = @ExitTimeExceded,
					  InsuranceRegistrationReleaseFee = @InsuranceRegistrationReleaseFee
                WHERE ConfigurationELSId = @ConfigurationELSId;
            END;
    END;


GO