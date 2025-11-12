SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-05-09 DJ/6470: Validación transaction id duplicado

CREATE PROCEDURE [dbo].[sp_GetInsuranceExistingPaymentByTransactionId]
@TransactionId VARCHAR(36)
AS 

BEGIN


select i.TransactionId from dbo.InsurancePolicy i where i.TransactionId = @TransactionId AND i.InsurancePaymentTypeId IS NOT NULL
UNION ALL
select m.TransactionId from dbo.InsuranceMonthlyPayment m where m.TransactionId = @TransactionId AND m.InsurancePaymentTypeId IS NOT NULL

	END
GO