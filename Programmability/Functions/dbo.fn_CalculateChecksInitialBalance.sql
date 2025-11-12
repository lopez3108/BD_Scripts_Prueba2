SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CalculateChecksInitialBalance](
@AgencyId   INT,
@EndDate DATETIME = NULL)
RETURNS DECIMAL(18, 2)
AS
   BEGIN  

   IF(@EndDate IS NULL)
   BEGIN

   SET @EndDate = DATEADD(DAY, 1, @EndDate)

   END
   
    RETURN ((



-- Closing check
+ ISNULL(
(
SELECT  
SUM(Amount)
FROM            dbo.ChecksEls
WHERE 
CAST(CreationDate as DATE) < CAST(@EndDate as DATE) AND
AgencyId = @AgencyId)

,0)

-- Closing check returned
+ ISNULL(
(
SELECT 
SUM(rp.Usd)
FROM            dbo.ReturnPayments rp INNER JOIN
dbo.ReturnPaymentMode rpm ON rpm.ReturnPaymentModeId = rp.ReturnPaymentModeId
WHERE 
rpm.Code = 'C01' AND
CAST(CreationDate as DATE) < CAST(@EndDate as DATE) AND
AgencyId = @AgencyId)
,0)

-- Closing check commission
+ ISNULL(
(

SELECT 
SUM(pc.Usd)
FROM            dbo.ProviderCommissionPayments pc INNER JOIN
dbo.ProviderCommissionPaymentTypes rpm ON rpm.ProviderCommissionPaymentTypeId = pc.ProviderCommissionPaymentTypeId INNER JOIN 
Providers ON Providers.ProviderId = pc.ProviderId
WHERE
rpm.Code = 'CODE02' AND
CAST(CreationDate as DATE) < CAST(@EndDate as DATE) AND
AgencyId = @AgencyId)
,0)

--Other commissions
+ ISNULL( (SELECT SUM(O.Usd)
         FROM [dbo].[ProviderCommissionPayments]
              INNER JOIN dbo.Users AS Users1 ON [dbo].[ProviderCommissionPayments].CreatedBy = Users1.UserId
              INNER JOIN [dbo].[OtherCommissions] O ON [dbo].[ProviderCommissionPayments].ProviderCommissionPaymentId = O.ProviderCommissionPaymentId
         WHERE 
		CAST(CreationDate as DATE) < CAST(@EndDate as DATE) AND
AgencyId = @AgencyId
               AND [dbo].[ProviderCommissionPayments].[CheckNumber] IS NOT NULL),0)

-- Process checks
- ISNULL(
(
SELECT 
SUM(Usd)
FROM            dbo.PaymentChecksAgentToAgent pc INNER JOIN
                         dbo.Agencies ON pc.FromAgency = dbo.Agencies.AgencyId INNER JOIN
                         dbo.Agencies AS Agencies_1 ON pc.ToAgency = Agencies_1.AgencyId INNER JOIN
                         dbo.Providers ON pc.ProviderId = dbo.Providers.ProviderId INNER JOIN
                         dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
WHERE 
CAST([Date] as DATE) < CAST(@EndDate as DATE) AND
FromAgency = @AgencyId)
,0)

-- Checks fee
--+ ISNULL(
--(SELECT  SUM(Fee)
--FROM            dbo.PaymentChecksAgentToAgent
--WHERE 
--FromAgency = @AgencyId AND
--CAST(dbo.PaymentChecksAgentToAgent.Date as date) < cast(@EndDate as DATE))
--,0)

---- Payments checks
- ISNULL(
(
SELECT 
SUM(Usd)
FROM            dbo.PaymentChecks pc INNER JOIN
                         dbo.Agencies ON pc.AgencyId = dbo.Agencies.AgencyId INNER JOIN
                         dbo.Providers ON pc.ProviderId = dbo.Providers.ProviderId INNER JOIN
                         dbo.ProviderTypes ON dbo.Providers.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
WHERE 
CAST([Date] as DATE) < CAST(@EndDate as DATE) AND
pc.AgencyId = @AgencyId)
,0)

-- Payments checks fee
--+ ISNULL(
--(SELECT  SUM(Fee)
--FROM            dbo.PaymentChecks
--WHERE 
--AgencyId = @AgencyId AND
--CAST(dbo.PaymentChecks.Date as date) < cast(@EndDate as DATE))
--,0)



))

END
GO