SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      JF
-- Create date: 16/07/2024 10:32 p. m.
-- Database:    copiaDevtest
-- Description: task 5919 Nuevo filtro(USD) en pantalla process checks
-- =============================================

CREATE PROCEDURE [dbo].[sp_GetPaymentChecksAgenttoagentByUser] @PaymentChecksAgentToAgentId INT = NULL,
--@PaymentCheckId INT = NULL,
@AgencyFromId INT = NULL,
@AgencyToId INT = NULL,
@DateFrom DATETIME = NULL,
@DateTo DATETIME = NULL,
@ProviderId INT = NULL,
@UserId INT = NULL,
@IsFromAdmin BIT = NULL,
@providerBatch VARCHAR(50) = NULL,
@numberChecks VARCHAR(50) = NULL,
@Usd DECIMAL(18, 2) = NULL
AS
BEGIN
  SELECT
    dbo.PaymentChecksAgentToAgent.PaymentChecksAgentToAgentId
   ,PaymentChecksAgentToAgent.CreationDate
   ,dbo.Agencies.Code + ' - ' + dbo.Agencies.Name AS FromAgency
   ,Agencies_1.Code + ' - ' + Agencies_1.Name AS ToAgency
   ,PaymentChecksAgentToAgent.Date AS [Date]
   ,PaymentChecksAgentToAgent.Usd
   ,PaymentChecksAgentToAgent.NumberChecks
   ,CASE
      WHEN dbo.PaymentChecksAgentToAgent.DeletedOn IS NOT NULL THEN 'DELETED'
      ELSE 'ACTIVE'
    END AS [Status]
   ,UPPER(Users1.Name) AS CreatedBy
   ,PaymentChecksAgentToAgent.DeletedOn
   ,UPPER(Users.Name) AS DeletedBy
   ,PaymentChecksAgentToAgent.FromDate
   ,PaymentChecksAgentToAgent.ToDate
   ,PaymentChecksAgentToAgent.Fee
   ,PaymentChecksAgentToAgent.CreatedBy CreatedById
   ,PaymentChecksAgentToAgent.UpdatedOn
   ,PaymentChecksAgentToAgent.UpdatedBy
   ,UsersUpd.Name UpdatedByName
   ,PaymentChecksAgentToAgent.FromAgency FromAgencyId
   ,PaymentChecksAgentToAgent.ToAgency ToAgencyId
   ,PaymentChecksAgentToAgent.LotNumber
   ,PaymentChecksAgentToAgent.providerBatch
   ,PaymentChecksAgentToAgent.ProviderId
   ,IsFromAdmin
   ,pr.Name + ISNULL((SELECT TOP 1
        CASE
          WHEN pt.Code = 'C02' THEN ' - ' + ISNULL(mn.Number, 'NOT REGISTERED')
          ELSE ''
        END
      FROM dbo.MoneyTransferxAgencyNumbers mn
      WHERE mn.ProviderId = pr.ProviderId

      AND mn.AgencyId = dbo.PaymentChecksAgentToAgent.ToAgency)
    , '') AS ProviderName
   ,FORMAT(PaymentChecksAgentToAgent.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat
   ,FORMAT(PaymentChecksAgentToAgent.FromDate, 'MM-dd-yyyy', 'en-US') FromDateFormat
   ,FORMAT(PaymentChecksAgentToAgent.ToDate, 'MM-dd-yyyy ', 'en-US') ToDateFormat
   ,FORMAT(PaymentChecksAgentToAgent.UpdatedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US') UpdatedOnFormat
  FROM dbo.PaymentChecksAgentToAgent
  LEFT OUTER JOIN dbo.Providers
    ON dbo.PaymentChecksAgentToAgent.ProviderId = dbo.Providers.ProviderId
  INNER JOIN dbo.Agencies
    ON dbo.PaymentChecksAgentToAgent.FromAgency = dbo.Agencies.AgencyId
  INNER JOIN dbo.Agencies AS Agencies_1
    ON dbo.PaymentChecksAgentToAgent.ToAgency = Agencies_1.AgencyId
  LEFT OUTER JOIN dbo.Users
    ON dbo.PaymentChecksAgentToAgent.DeletedBy = dbo.Users.UserId
  INNER JOIN dbo.Users AS Users1
    ON dbo.PaymentChecksAgentToAgent.CreatedBy = Users1.UserId
  LEFT JOIN dbo.Users AS UsersUpd
    ON dbo.PaymentChecksAgentToAgent.UpdatedBy = UsersUpd.UserId
  INNER JOIN dbo.Providers pr
    ON pr.ProviderId = dbo.PaymentChecksAgentToAgent.ProviderId
  INNER JOIN dbo.ProviderTypes pt
    ON pt.ProviderTypeId = pr.ProviderTypeId
  --INNER JOIN dbo.ChecksEls ce ON PaymentChecksAgentToAgent.PaymentChecksAgentToAgentId = ce.PaymentChecksAgentToAgentId
  WHERE (dbo.PaymentChecksAgentToAgent.FromAgency = @AgencyFromId
  OR @AgencyFromId IS NULL)
  AND (dbo.PaymentChecksAgentToAgent.ToAgency = @AgencyToId
  OR @AgencyToId IS NULL)
  AND (CAST(dbo.PaymentChecksAgentToAgent.CreationDate AS Date) >= CAST(@DateFrom AS Date)
  OR @DateFrom IS NULL)
  AND (CAST(dbo.PaymentChecksAgentToAgent.CreationDate AS Date) <= CAST(@DateTo AS Date)
  OR @DateTo IS NULL)
  AND (dbo.PaymentChecksAgentToAgent.CreatedBy = @UserId
  OR @UserId IS NULL)
  AND (dbo.PaymentChecksAgentToAgent.ProviderId = @ProviderId
  OR @ProviderId IS NULL)
  AND (@PaymentChecksAgentToAgentId IS NULL
  OR dbo.PaymentChecksAgentToAgent.PaymentChecksAgentToAgentId = @PaymentChecksAgentToAgentId)
  AND (dbo.PaymentChecksAgentToAgent.providerBatch = @providerBatch
  OR @providerBatch IS NULL)

  AND ((@numberChecks IS NULL
  OR EXISTS (SELECT TOP 1
      1
    FROM ChecksEls ckl
    WHERE ckl.CheckNumber = @numberChecks
    AND ckl.PaymentChecksAgentToAgentId = dbo.PaymentChecksAgentToAgent.PaymentChecksAgentToAgentId)
  )
  OR (@numberChecks IS NULL
  OR EXISTS (SELECT TOP 1
      1
    FROM ReturnPayments ckl
    WHERE ckl.CheckNumber = @numberChecks
    AND ckl.PaymentChecksAgentToAgentId = dbo.PaymentChecksAgentToAgent.PaymentChecksAgentToAgentId)
  )OR (@numberChecks IS NULL
  OR EXISTS (SELECT TOP 1
      1
    FROM dbo.ProviderCommissionPayments pcp
    WHERE pcp.CheckNumber = @numberChecks
    AND pcp.PaymentChecksAgentToAgentId = dbo.PaymentChecksAgentToAgent.PaymentChecksAgentToAgentId)
  ))

 AND ((@Usd IS NULL
  OR EXISTS (SELECT TOP 1
      1
    FROM ChecksEls ckl
    WHERE ckl.Amount = @Usd
    AND ckl.PaymentChecksAgentToAgentId = dbo.PaymentChecksAgentToAgent.PaymentChecksAgentToAgentId)
  )
  OR (@Usd IS NULL
  OR EXISTS (SELECT TOP 1
      1
    FROM ReturnPayments ckl
    WHERE ckl.Usd = @Usd
    AND ckl.PaymentChecksAgentToAgentId = dbo.PaymentChecksAgentToAgent.PaymentChecksAgentToAgentId)
  )OR (@Usd IS NULL
  OR EXISTS (SELECT TOP 1
      1
    FROM dbo.ProviderCommissionPayments pcp
    WHERE pcp.Usd = @Usd
    AND pcp.PaymentChecksAgentToAgentId = dbo.PaymentChecksAgentToAgent.PaymentChecksAgentToAgentId)
  ))

  --TO DO Falta los number check de los pagos de comisiones 


  ORDER BY PaymentChecksAgentToAgent.LotNumber ASC,
  PaymentChecksAgentToAgent.CreationDate;
END;
GO