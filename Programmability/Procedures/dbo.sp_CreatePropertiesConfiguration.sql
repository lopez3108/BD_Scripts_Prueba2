SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2024-07-29 DJ/5972: Added DepositRefundFee field
CREATE PROCEDURE [dbo].[sp_CreatePropertiesConfiguration]
(@PropertiesConfigurationId INT            = NULL, 
 @FeeDue                    DECIMAL(18, 2)  = NULL, 
 @Dayslate                  INT            = NULL, 
 @MonthlyPaymentDate        INT            = NULL,
                @DaysMaxiAband INT            = NULL,
				 @FeeNfs                   DECIMAL(18, 2)  = NULL,
				 @FeeDueLateInformation VARCHAR(3500) = NULL,
				 @DepositInformation VARCHAR(3500) = NULL,
				 @MoveInFeeInformation VARCHAR(3500) = NULL,
				 @SendTextConsentInformation  VARCHAR(3500) = NULL,
				 @DepositRefundFee                   DECIMAL(18, 2) = 0

)
AS
    BEGIN
        IF(@PropertiesConfigurationId IS NULL)
            BEGIN
                INSERT INTO [dbo].[PropertiesConfiguration]
                ([FeeDue], 
                 Dayslate, 
                 MonthlyPaymentDate,
				 DaysMaxiAband,
				 FeeNfs,
				 FeeDueLateLegend,
				 DepositLegend,
				 MoveInFeeLegend,
				 SendTextConsentLegend,
				 DepositRefundFee
                )
                VALUES
                (@FeeDue, 
                 @Dayslate, 
                 @MonthlyPaymentDate,
				 @DaysMaxiAband,
				 @FeeNfs,
				 @FeeDueLateInformation,
				 @DepositInformation,
				 @MoveInFeeInformation,
				 @SendTextConsentInformation,
				 @DepositRefundFee
                );
                SELECT @@IDENTITY;
            END;
        UPDATE [dbo].[PropertiesConfiguration]
          SET 
              [FeeDue] = @FeeDue, 
              Dayslate = @Dayslate, 
              MonthlyPaymentDate = @MonthlyPaymentDate,
			   DaysMaxiAband = @DaysMaxiAband,
				 FeeNfs = @FeeNfs,
				 FeeDueLateLegend = @FeeDueLateInformation,
				 DepositLegend = @DepositInformation,
				 MoveInFeeLegend = @MoveInFeeInformation,
				 SendTextConsentLegend = @SendTextConsentInformation,
				 DepositRefundFee = @DepositRefundFee
        WHERE PropertiesConfigurationId = @PropertiesConfigurationId;
        SELECT @PropertiesConfigurationId;
    END;
GO