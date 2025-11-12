SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-02-14 DJ/6344: Pago de Comisiones a Proveedores de Tipo INSURANCE

CREATE PROCEDURE [dbo].[sp_GetInsuranceProviderCommissions](
@AgencyId INT, 
@ProviderId INT,
@FromDate DATETIME = NULL,
@ToDate DATETIME = NULL,
@Paid BIT = NULL
)
AS
     BEGIN

	 DECLARE @statusPaid INT
	 SET @statusPaid = (SELECT TOP 1 InsurancePolicyStatusId FROM dbo.InsurancePolicyStatus i WHERE i.Code = 'C02')
       
	   -- New policy

	   SELECT 
	   1 as [Index],
	   ISNULL(SUM(ISNULL(i.FeeService,0) + ISNULL(i.CommissionUsd,0)),0) as CommissionTotal,
	   COUNT(i.InsurancePolicyId) as Quantity 
	   FROM dbo.InsurancePolicy i
	   WHERE i.CreatedByMonthlyPayment = CAST(0 as BIT) AND
	   i.ProviderId = @ProviderId AND
	   i.CreatedInAgencyId = @AgencyId AND
	   (@FromDate IS NULL OR CAST(i.CreationDate as DATE) >= CAST(@FromDate as DATE)) AND
	   (@ToDate IS NULL OR CAST(i.CreationDate as DATE) <= CAST(@ToDate as DATE)) AND
	   (@Paid IS NULL OR (@Paid = CAST(0 as BIT) AND i.PaymentStatusId <> @statusPaid) OR (@Paid = CAST(1 as BIT) AND i.PaymentStatusId = @statusPaid))

	   UNION ALL

	   	   -- Monthly payment

	   SELECT 
	   2 as [Index],
	   ISNULL(SUM(ISNULL(i.MonthlyPaymentServiceFee,0) + ISNULL(i.CommissionUsd,0)),0) as CommissionTotal,
	   COUNT(i.InsuranceMonthlyPaymentId) as Quantity 
	   FROM dbo.InsuranceMonthlyPayment i INNER JOIN
	   dbo.InsurancePolicy m ON m.InsurancePolicyId = i.InsurancePolicyId INNER JOIN
	   dbo.InsuranceCommissionType t ON t.InsuranceCommissionTypeId = i.InsuranceCommissionTypeId
	   WHERE t.Code = 'C04' AND -- MONTHLY PAYMENT
	   m.ProviderId = @ProviderId AND
	   i.CreatedInAgencyId = @AgencyId AND
	   (@FromDate IS NULL OR CAST(i.CreationDate as DATE) >= CAST(@FromDate as DATE)) AND
	   (@ToDate IS NULL OR CAST(i.CreationDate as DATE) <= CAST(@ToDate as DATE)) AND
	    (@Paid IS NULL OR (@Paid = CAST(0 as BIT) AND i.PaymentStatusId <> @statusPaid) OR (@Paid = CAST(1 as BIT) AND i.PaymentStatusId = @statusPaid))

	   UNION ALL

	   	   -- ENDORSEMENT

	   SELECT 
	   3 as [Index],
	   ISNULL(SUM(ISNULL(i.MonthlyPaymentServiceFee,0) + ISNULL(i.CommissionUsd,0)),0) as CommissionTotal,
	   COUNT(i.InsuranceMonthlyPaymentId) as Quantity 
	   FROM dbo.InsuranceMonthlyPayment i INNER JOIN
	   dbo.InsurancePolicy m ON m.InsurancePolicyId = i.InsurancePolicyId INNER JOIN
	   dbo.InsuranceCommissionType t ON t.InsuranceCommissionTypeId = i.InsuranceCommissionTypeId
	   WHERE t.Code = 'C03' AND -- ENDORSEMENT
	   m.ProviderId = @ProviderId AND
	   i.CreatedInAgencyId = @AgencyId AND
	   (@FromDate IS NULL OR CAST(i.CreationDate as DATE) >= CAST(@FromDate as DATE)) AND
	   (@ToDate IS NULL OR CAST(i.CreationDate as DATE) <= CAST(@ToDate as DATE)) AND
	    (@Paid IS NULL OR (@Paid = CAST(0 as BIT) AND i.PaymentStatusId <> @statusPaid) OR (@Paid = CAST(1 as BIT) AND i.PaymentStatusId = @statusPaid))

	   UNION ALL

	   -- POLICY RENEWAL

	   SELECT 
	   4 as [Index],
	   ISNULL(SUM(ISNULL(i.MonthlyPaymentServiceFee,0) + ISNULL(i.CommissionUsd,0)),0) as CommissionTotal,
	   COUNT(i.InsuranceMonthlyPaymentId) as Quantity 
	   FROM dbo.InsuranceMonthlyPayment i INNER JOIN
	   dbo.InsurancePolicy m ON m.InsurancePolicyId = i.InsurancePolicyId INNER JOIN
	   dbo.InsuranceCommissionType t ON t.InsuranceCommissionTypeId = i.InsuranceCommissionTypeId
	   WHERE t.Code = 'C02' AND -- POLICY RENEWAL
	   m.ProviderId = @ProviderId AND
	   i.CreatedInAgencyId = @AgencyId AND
	   (@FromDate IS NULL OR CAST(i.CreationDate as DATE) >= CAST(@FromDate as DATE)) AND
	   (@ToDate IS NULL OR CAST(i.CreationDate as DATE) <= CAST(@ToDate as DATE)) AND
	    (@Paid IS NULL OR (@Paid = CAST(0 as BIT) AND i.PaymentStatusId <> @statusPaid) OR (@Paid = CAST(1 as BIT) AND i.PaymentStatusId = @statusPaid))

	   UNION ALL

	   -- Registration release

	   SELECT 
	   5 as [Index],
	   ISNULL(SUM(ISNULL(i.RegistrationReleaseSOSFee,0)),0) as CommissionTotal,
	   COUNT(i.InsuranceRegistrationId) as Quantity 
	   FROM dbo.InsuranceRegistration i
	   WHERE i.ProviderId = @ProviderId AND
	   i.CreatedInAgencyId = @AgencyId AND
	   (@FromDate IS NULL OR CAST(i.CreationDate as DATE) >= CAST(@FromDate as DATE)) AND
	   (@ToDate IS NULL OR CAST(i.CreationDate as DATE) <= CAST(@ToDate as DATE)) AND
	    (@Paid IS NULL OR (@Paid = CAST(0 as BIT) AND i.PaymentStatusId <> @statusPaid) OR (@Paid = CAST(1 as BIT) AND i.PaymentStatusId = @statusPaid))



     END;
GO