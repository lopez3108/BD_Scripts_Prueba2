SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--DROP PROCEDURE [dbo].[sp_SaveValidateProcessCheckEls]
CREATE PROCEDURE [dbo].[sp_SaveValidateProcessChecks]
(
@CheckElsId      INT        = NULL,
@ReturnPaymentsId      INT        = NULL,
@ProviderCommissionPaymentId      INT        = NULL,
@OtherCommissionId      INT        = NULL,
@ValidatedBy      INT        = NULL,
@ValidatedOn        DATETIME = NULL,
@LotNumber      INT        = NULL,
@PaymentChecksAgentToAgentId int = NULL,
@CheckType VARCHAR(1),
@ProccesCheckReturned BIT = NULL
)
AS
     BEGIN
	 IF @CheckType = 'E'
	 BEGIN
                 UPDATE [dbo].ChecksEls
                   SET
                       ValidatedBy = @ValidatedBy,
                       ValidatedOn = @ValidatedOn,
					   LotNumber = @LotNumber,
					   PaymentChecksAgentToAgentId = @PaymentChecksAgentToAgentId,	
					   ProccesCheckReturned = @ProccesCheckReturned
                 WHERE CheckElsId = @CheckElsId;
		END
		ELSE IF @CheckType = 'R'
	 BEGIN
                 UPDATE [dbo].[ReturnPayments]
                   SET
                       ValidatedBy = @ValidatedBy,
                       ValidatedOn = @ValidatedOn,
					   LotNumber = @LotNumber,
					   PaymentChecksAgentToAgentId = @PaymentChecksAgentToAgentId,
               ProccesCheckReturned = @ProccesCheckReturned				   
                 WHERE ReturnPaymentsId = @ReturnPaymentsId;
		END
			ELSE IF @CheckType = 'P'
	 BEGIN
                  UPDATE [dbo].ProviderCommissionPayments
                   SET
                       ValidatedBy = @ValidatedBy,
                       ValidatedOn = @ValidatedOn,
					   LotNumber = @LotNumber,
					   PaymentChecksAgentToAgentId = @PaymentChecksAgentToAgentId ,
               ProccesCheckReturned = @ProccesCheckReturned					   
                 WHERE ProviderCommissionPaymentId = @ProviderCommissionPaymentId;
		END
				ELSE IF @CheckType = 'O'
	 BEGIN
                  UPDATE [dbo].[OtherCommissions]
                   SET
                       ValidatedBy = @ValidatedBy,
                       ValidatedOn = @ValidatedOn,
					   LotNumber = @LotNumber,
					   PaymentChecksAgentToAgentId = @PaymentChecksAgentToAgentId ,
               ProccesCheckReturned = @ProccesCheckReturned				   
                 WHERE OtherCommissionId = @OtherCommissionId;
		END
     END;
GO