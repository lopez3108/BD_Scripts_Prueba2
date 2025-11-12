SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--sp_GetPaymentChecksElsAgenttoagent 1,'20180908','20181119',null
CREATE PROCEDURE [dbo].[sp_GetPaymentChecksElsAgenttoagent] @AgencyFromId INT,
@DateFrom DATETIME = NULL,
@DateTo DATETIME = NULL,
@ListCashiersId VARCHAR(1000) = NULL,
@LotNumber SMALLINT = NULL
AS
BEGIN
  SELECT
    CheckElsId AS CheckElsId
   ,NULL ReturnPaymentsId
   ,NULL ProviderCommissionPaymentId
   ,NULL OtherCommissionId
   ,ProviderTypeId
   ,Amount
   ,ChecksEls.CreationDate
   ,ChecksEls.CreatedBy
   ,AgencyId
   ,ValidatedOn
   ,ValidatedBy
   ,CASE
      WHEN ValidatedBy IS NULL THEN 'false'
      ELSE 'true'
    END [BoolValidated]
   ,'E' AS CheckType
   ,CashierId
   ,UPPER(Users1.Name) AS CreatedByName
   ,Amount * (ISNULL(Fee, 0) / 100) Fee
--   ,CheckDate AS CheckDate1
   ,FORMAT(CheckDate, 'MM-dd-yyyy', 'en-US') CheckDate
   ,ProccesCheckReturned
   ,Routing
   ,Account
   ,CheckNumber
   ,(ISNULL(pc.Usd, 0)) AS Discount
   ,(Amount) - ((ISNULL(Amount, 0)) * (ISNULL(Fee, 0) / 100)) + (ISNULL(pc.Usd, 0)) AS TotalToPay
   ,ISNULL(Fee, 0) AS FeePorcentage
  FROM [dbo].[ChecksEls]
  INNER JOIN dbo.Users AS Users1
    ON [dbo].[ChecksEls].CreatedBy = Users1.UserId
  INNER JOIN [dbo].[Cashiers]
    ON [dbo].[Cashiers].UserId = Users1.UserId
  LEFT JOIN PromotionalCodesStatus P
    ON ChecksEls.CheckElsId = P.CheckId
  LEFT JOIN PromotionalCodes pc
    ON pc.PromotionalCodeId = P.PromotionalCodeId
  WHERE
  --CAST([dbo].[ChecksEls].[CreationDate] AS DATE) BETWEEN CAST(@DateFrom AS DATE) AND CAST(@DateTo AS DATE)
  ((CAST(dbo.[ChecksEls].CreationDate AS DATE) >= CAST(@DateFrom AS DATE)
  OR @DateFrom IS NULL)
  AND (CAST(dbo.[ChecksEls].CreationDate AS DATE) <= CAST(@DateTo AS DATE)
  OR @DateTo IS NULL))
  AND [dbo].[ChecksEls].[AgencyId] = @AgencyFromId
  AND [dbo].[ChecksEls].[ValidatedBy] IS NULL
  AND ([dbo].[Cashiers].CashierId IN (SELECT
      item
    FROM dbo.FN_ListToTableInt(@ListCashiersId))
  OR @ListCashiersId IS NULL)
  AND ([ChecksEls].LotNumber = @LotNumber
  OR @LotNumber IS NULL)
  UNION ALL
  SELECT
    NULL CheckElsId
   ,ReturnPaymentsId
   ,NULL ProviderCommissionPaymentId
   ,NULL OtherCommissionId
   ,NULL AS ProviderTypeId
   ,[dbo].[ReturnPayments].Usd AS Amount
   ,CreationDate
   ,CreatedBy
   ,AgencyId
   ,ValidatedOn
   ,ValidatedBy
   ,CASE
      WHEN ValidatedBy IS NULL THEN 'false'
      ELSE 'true'
    END [BoolValidated]
   ,'R' AS CheckType
   ,CashierId
   ,UPPER(Users1.Name) AS CreatedByName
   ,0 Fee
  
    ,FORMAT(CheckDate, 'MM-dd-yyyy', 'en-US') CheckDate
   ,ProccesCheckReturned
   ,NULL Routing
   ,NULL Account
   ,CheckNumber
   ,0 Discount
   ,0 TotalToPay
   ,0 FeePorcentage
  FROM [dbo].[ReturnPayments]
  INNER JOIN dbo.Users AS Users1
    ON [dbo].[ReturnPayments].CreatedBy = Users1.UserId
  INNER JOIN [dbo].[Cashiers]
    ON [dbo].[Cashiers].UserId = Users1.UserId
  INNER JOIN [dbo].[ReturnPaymentMode] rm
    ON rm.ReturnPaymentModeId = [dbo].[ReturnPayments].ReturnPaymentModeId
  WHERE
  --CAST([dbo].[ReturnPayments].[CreationDate] AS DATE) BETWEEN CAST(@DateFrom AS DATE) AND CAST(@DateTo AS DATE)
  ((CAST(dbo.ReturnPayments.CreationDate AS DATE) >= CAST(@DateFrom AS DATE)
  OR @DateFrom IS NULL)
  AND (CAST(dbo.ReturnPayments.CreationDate AS DATE) <= CAST(@DateTo AS DATE)
  OR @DateTo IS NULL))
  AND [dbo].[ReturnPayments].[AgencyId] = @AgencyFromId
  AND [dbo].[ReturnPayments].[ValidatedBy] IS NULL
  AND rm.Code = 'C01'
  AND ([dbo].[Cashiers].CashierId IN (SELECT
      item
    FROM dbo.FN_ListToTableInt(@ListCashiersId))
  OR @ListCashiersId IS NULL)
  AND (ReturnPayments.LotNumber = @LotNumber
  OR @LotNumber IS NULL)
  UNION ALL
  SELECT
    NULL CheckElsId
   ,NULL ReturnPaymentsId
   ,[dbo].[ProviderCommissionPayments].ProviderCommissionPaymentId
   ,NULL OtherCommissionId
   ,NULL AS ProviderTypeId
   ,[dbo].[ProviderCommissionPayments].Usd AS Amount
   ,CreationDate
   ,CreatedBy
   ,AgencyId
   ,[dbo].[ProviderCommissionPayments].ValidatedOn
   ,[dbo].[ProviderCommissionPayments].ValidatedBy
   ,CASE
      WHEN [dbo].[ProviderCommissionPayments].ValidatedBy IS NULL THEN 'false'
      ELSE 'true'
    END [BoolValidated]
   ,'P' AS CheckType
   ,NULL AS CashierId
   ,UPPER(Users1.Name) AS CreatedByName
   ,0 Fee
   , FORMAT([dbo].[ProviderCommissionPayments].CheckDate, 'MM-dd-yyyy', 'en-US')  CheckDate
   ,ProccesCheckReturned
   ,NULL Routing
   ,NULL Account
   , CheckNumber
   ,0 Discount
   ,0 TotalToPay
   ,0 FeePorcentage
  FROM [dbo].[ProviderCommissionPayments]
  INNER JOIN dbo.Users AS Users1
    ON [dbo].[ProviderCommissionPayments].CreatedBy = Users1.UserId
  --LEFT JOIN [dbo].[OtherCommissions] O ON [dbo].[ProviderCommissionPayments].ProviderCommissionPaymentId = O.ProviderCommissionPaymentId
  WHERE
  -- CAST([dbo].[ProviderCommissionPayments].[CreationDate] AS DATE) BETWEEN CAST(@DateFrom AS DATE) AND CAST(@DateTo AS DATE)
  ((CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE) >= CAST(@DateFrom AS DATE)
  OR @DateFrom IS NULL)
  AND (CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE) <= CAST(@DateTo AS DATE)
  OR @DateTo IS NULL))
  AND [dbo].[ProviderCommissionPayments].[AgencyId] = @AgencyFromId
  AND [dbo].[ProviderCommissionPayments].[ValidatedBy] IS NULL
  AND [dbo].[ProviderCommissionPayments].[CheckNumber] IS NOT NULL
  UNION ALL
  SELECT
    NULL AS CheckElsId
   ,NULL ReturnPaymentsId
   ,[dbo].[ProviderCommissionPayments].ProviderCommissionPaymentId
   ,O.OtherCommissionId
   ,NULL AS ProviderTypeId
   ,O.Usd AS Amount
   ,CreationDate
   ,CreatedBy
   ,AgencyId
   ,[dbo].[ProviderCommissionPayments].ValidatedOn
   ,[dbo].[ProviderCommissionPayments].ValidatedBy
   ,CASE
      WHEN [dbo].[ProviderCommissionPayments].ValidatedBy IS NULL THEN 'false'
      ELSE 'true'
    END [BoolValidated]
   ,'O' AS CheckType
   ,NULL AS CashierId
   ,UPPER(Users1.Name) AS CreatedByName
   ,0 Fee
   ,FORMAT(O.CheckDate, 'MM-dd-yyyy', 'en-US')  CheckDate 
   ,O.ProccesCheckReturned
   ,NULL Routing
   ,NULL Account
   ,O.CheckNumber
   ,0 Discount
   ,0 TotalToPay
   ,0 FeePorcentage
  FROM [dbo].[ProviderCommissionPayments]
  INNER JOIN dbo.Users AS Users1
    ON [dbo].[ProviderCommissionPayments].CreatedBy = Users1.UserId
  INNER JOIN [dbo].[OtherCommissions] O
    ON [dbo].[ProviderCommissionPayments].ProviderCommissionPaymentId = O.ProviderCommissionPaymentId
  WHERE
  --CAST([dbo].[ProviderCommissionPayments].[CreationDate] AS DATE) BETWEEN CAST(@DateFrom AS DATE) AND CAST(@DateTo AS DATE)
  ((CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE) >= CAST(@DateFrom AS DATE)
  OR @DateFrom IS NULL)
  AND (CAST(dbo.ProviderCommissionPayments.CreationDate AS DATE) <= CAST(@DateTo AS DATE)
  OR @DateTo IS NULL))
  AND [dbo].[ProviderCommissionPayments].[AgencyId] = @AgencyFromId
  AND O.[ValidatedBy] IS NULL
  AND O.CheckNumber IS NOT NULL
  ORDER BY Amount ASC

END;

GO