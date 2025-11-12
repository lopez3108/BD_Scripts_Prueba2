SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-07-30 DJ/5979: Added DepositRefundFee field
-- 2024-08-07 DJ/5979: Admin must be able to create reposit refund, payment type added to deposit refund
-- 2024-08-22 DJ/5974: Checking DB data before savif refund to avoid data overwriting
-- 2025-06-19 DJ/6592: MODULO PROPIEDADES - URL DETAILS PROPERTIES - SENT 05-27-2025

CREATE PROCEDURE [dbo].[sp_CreateDepositRefund]
 (
		@ContractId int,
      @CurrentDate DATETIME,
	  @RefundBy INT,
	  @AgencyRefundId INT = NULL,
	  @DepositRefundPaymentTypeId INT = NULL,
	  @DepositRefundBankAccountId INT = NULL,
	  @DepositRefundCheckNumber VARCHAR(15) = NULL,
	  @AchDate DATETIME = NULL

    )
AS 

BEGIN

declare @depositAlreadyPaid DATETIME
set @depositAlreadyPaid = (SELECT TOP 1 RefundDate FROM dbo.Contract WHERE ContractId = @ContractId)

IF(@depositAlreadyPaid IS NOT NULL)
BEGIN

SELECT -1 -- 5974

END
ELSE
BEGIN

declare @availableDeposit decimal(18,2)
set @availableDeposit = ISNULL((SELECT TOP 1 ContractAvailableRefund FROM [dbo].[FN_GetContractDepositInformation](@ContractId, @CurrentDate)), 0)

UPDATE Contract 
SET SetAvailableDeposit = 0, 
RefundDate = @CurrentDate, 
RefundBy = @RefundBy,
AgencyRefundId = @AgencyRefundId, 
RefundUsd = @availableDeposit,
DepositRefundPaymentTypeId = @DepositRefundPaymentTypeId, -- 5979
DepositRefundBankAccountId = @DepositRefundBankAccountId,
DepositRefundCheckNumber = @DepositRefundCheckNumber,
AchDate = @AchDate
WHERE ContractId = @ContractId

INSERT INTO [dbo].[ContractNotes]
           ([ContractId]
           ,[Note]
           ,[CreationDate]
           ,[CreatedBy])
     VALUES
           (@ContractId
           ,'DEPOSIT REFUND MADE $' + CAST(@availableDeposit as VARCHAR(12))
           ,@CurrentDate
           ,@RefundBy)

		   SELECT @ContractId
END

	END
GO