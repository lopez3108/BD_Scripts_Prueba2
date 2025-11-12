SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE   FUNCTION [dbo].[FN_GetContractDepositInformation](@ContractId   INT, 
@Date DATETIME = NULL
                                                   
                                                   ) 
RETURNS @result TABLE
(ContractId INT ,
ContractDeposit DECIMAL(18,2),
ContractUsedDeposit DECIMAL(18,2),
ContractAvailableDeposit DECIMAL(18,2),
ContractAvailableRefund DECIMAL(18,2)
)
AS
     BEGIN

	 DECLARE @ContractDeposit DECIMAL(18,2)
	 SET @ContractDeposit = (SELECT TOP 1 DownPayment FROM dbo.[Contract] WHERE ContractId = @ContractId)

	 

	   DECLARE @ContractUsedDeposit DECIMAL(18,2)
	 SET @ContractUsedDeposit = ISNULL((SELECT TOP 1 SUM(DepositUsed) FROM dbo.PropertiesBillLabor WHERE ContractId = @ContractId),0)

	 DECLARE @depositPaid DECIMAL(18,2)
	SET @depositPaid = (SELECT ISNULL(SUM(Usd),0) FROM DepositFinancingPayments WHERE ContractId = @ContractId)

	IF(@Date IS NOT NULL)
	 BEGIN
	 SET @depositPaid = @depositPaid + [dbo].[fn_GetDepositRefundTotal](@ContractId, @Date)
	 END

	DECLARE @ContractAvailableDeposit DECIMAL(18,2)
	 SET @ContractAvailableDeposit = @depositPaid - @ContractUsedDeposit

	 if(@ContractAvailableDeposit < 0)
	 BEGIN

	 SET @ContractAvailableDeposit = 0

	 END

	   
	   INSERT INTO @result
         (ContractId,
		 ContractDeposit,
		 ContractUsedDeposit,
		 ContractAvailableDeposit,
		 ContractAvailableRefund
         )
		 VALUES
         (
            @ContractId,
			@ContractDeposit,
			@ContractUsedDeposit,
			@ContractAvailableDeposit,
			@ContractAvailableDeposit
         );

         RETURN;
     END;
GO