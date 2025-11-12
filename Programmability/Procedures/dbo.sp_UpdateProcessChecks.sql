SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--ALTER   PROCEDURE [dbo].[sp_UpdatePaymentChecksEls]
CREATE PROCEDURE [dbo].[sp_UpdateProcessChecks]
(@CheckElsId    INT = NULL,
@ReturnPaymentsId      INT        = NULL,
@ProviderCommissionPaymentId      INT        = NULL,
@OtherCommissionId      INT        = NULL,
 @ValidatedOn	DATETIME,
 @ValidatedBy	INT = NULL,
 @CheckType		CHAR(1) = NULL,
 @LotNumber		SMALLINT = NULL,
 @providerBatch	VARCHAR(50) = NULL,
 @PaymentChecksAgentToAgentId int = NULL
)
AS 

BEGIN

	if (@ValidatedBy = 0)
		SET @ValidatedBy = NULL;

	IF (@CheckType = 'E')
	BEGIN
		UPDATE [dbo].[ChecksEls] 
		SET ValidatedOn = @ValidatedOn,
			 ValidatedBy = @ValidatedBy,
			 LotNumber = @LotNumber,
       providerBatch = @providerBatch,
			 PaymentChecksAgentToAgentId = @PaymentChecksAgentToAgentId
		WHERE CheckElsId = @CheckElsId;
		SELECT @CheckElsId
	END

	IF (@CheckType = 'R')
	BEGIN
		UPDATE [dbo].[ReturnPayments]
		SET ValidatedOn = @ValidatedOn,
			 ValidatedBy = @ValidatedBy,
			 LotNumber = @LotNumber,
			 PaymentChecksAgentToAgentId = @PaymentChecksAgentToAgentId
		WHERE ReturnPaymentsId = @ReturnPaymentsId;
		SELECT @ReturnPaymentsId
	END

	IF (@CheckType = 'P')
	BEGIN
		UPDATE [dbo].[ProviderCommissionPayments]
		SET ValidatedOn = @ValidatedOn,
			 ValidatedBy = @ValidatedBy,
			 LotNumber = @LotNumber,
			 PaymentChecksAgentToAgentId = @PaymentChecksAgentToAgentId
		WHERE ProviderCommissionPaymentId = @ProviderCommissionPaymentId;
		SELECT @ProviderCommissionPaymentId
	END

	IF (@CheckType = 'O')
	BEGIN
		UPDATE [dbo].[OtherCommissions]
		SET ValidatedOn = @ValidatedOn,
			 ValidatedBy = @ValidatedBy,
			 LotNumber = @LotNumber,
			 PaymentChecksAgentToAgentId = @PaymentChecksAgentToAgentId
		WHERE OtherCommissionId = @OtherCommissionId;
		SELECT @OtherCommissionId
	END

END
GO