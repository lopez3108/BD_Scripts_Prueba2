SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetPaymentChecksElsAgenttoagentWithProcess]
                 @Date datetime = NULL, @UserId int = NULL, @LotNumber smallint = NULL, @PaymentChecksAgentToAgentId int = NULL
--@PaymentCheckId  INT = NULL
AS
BEGIN
  --CHECKS ELS
  SELECT CheckElsId AS CheckElsId
  , NULL ReturnPaymentsId
  , NULL ProviderCommissionPaymentId
  , NULL OtherCommissionId
  , ProviderTypeId
  , Amount AS Amount
  , ChecksEls.CreationDate
  , ChecksEls.CreatedBy
  , AgencyId
  , ValidatedOn
  , ValidatedBy
  , 'E' AS CheckType
  , CashierId
  , UPPER(Users1.Name) AS CreatedByName
  , Amount * (ISNULL(Fee, 0) / 100) Fee
  --   ,CheckDate
  , FORMAT(CheckDate, 'MM-dd-yyyy', 'en-US') CheckDate
  , ProccesCheckReturned
  , Routing
  , Account
  , CheckNumber
  , (ISNULL(pc.Usd, 0)) AS Discount
  , (Amount) - ((ISNULL(Amount, 0)) * (ISNULL(Fee, 0) / 100)) + (ISNULL(pc.Usd, 0)) AS TotalToPay
  , Fee AS FeePorcentage

  FROM [dbo].[ChecksEls]
       INNER JOIN
       dbo.Users AS Users1
       ON [dbo].[ChecksEls].CreatedBy = Users1.UserId
       INNER JOIN
       [dbo].[Cashiers]
       ON [dbo].[Cashiers].UserId = Users1.UserId
       LEFT JOIN
       PromotionalCodesStatus P
       ON ChecksEls.CheckElsId = P.CheckId
       LEFT JOIN
       PromotionalCodes pc
       ON pc.PromotionalCodeId = P.PromotionalCodeId
  WHERE
        --		   ((CAST(dbo.[ChecksEls].ValidatedOn AS DATE) = CAST(@Date AS DATE) OR @Date IS NULL))
        [dbo].[ChecksEls].[ValidatedBy] = @UserId AND
        (LotNumber = @LotNumber OR
        @LotNumber IS NULL) AND
        (PaymentChecksAgentToAgentId = @PaymentChecksAgentToAgentId OR
        @PaymentChecksAgentToAgentId IS NULL)

  UNION ALL
  -- RETURNED PAYMENTS
  SELECT NULL CheckElsId
  , ReturnPaymentsId
  , NULL ProviderCommissionPaymentId
  , NULL OtherCommissionId
  , NULL AS ProviderTypeId
  , [dbo].[ReturnPayments].Usd AS Amount
  , CreationDate
  , CreatedBy
  , AgencyId
  , ValidatedOn
  , ValidatedBy
  , 'R' AS CheckType
  , CashierId
  , UPPER(Users1.Name) AS CreatedByName
  , 0 Fee
  --   , [dbo].[ReturnPayments].CheckDate as CheckDate
  , FORMAT([dbo].[ReturnPayments].CheckDate, 'MM-dd-yyyy', 'en-US') CheckDate
  , ProccesCheckReturned
  , NULL Routing
  , NULL Account
  , CheckNumber
  , 0 Discount
  , 0 TotalToPay
  , 0 FeePorcentage
  FROM [dbo].[ReturnPayments]
       INNER JOIN
       dbo.Users AS Users1
       ON [dbo].[ReturnPayments].CreatedBy = Users1.UserId
       INNER JOIN
       [dbo].[Cashiers]
       ON [dbo].[Cashiers].UserId = Users1.UserId
       INNER JOIN
       [dbo].[ReturnPaymentMode] rm
       ON rm.ReturnPaymentModeId = [dbo].[ReturnPayments].ReturnPaymentModeId
  WHERE
        --CAST([dbo].[ReturnPayments].[CreationDate] AS DATE) BETWEEN CAST(@DateFrom AS DATE) AND CAST(@DateTo AS DATE)
        --            (CAST(dbo.ReturnPayments.CreationDate AS DATE) = CAST(@Date AS DATE) OR @Date IS NULL)
        [dbo].ReturnPayments.[ValidatedBy] = @UserId AND
        (ReturnPayments.LotNumber = @LotNumber OR
        @LotNumber IS NULL) AND
        (ReturnPayments.PaymentChecksAgentToAgentId = @PaymentChecksAgentToAgentId OR
        @PaymentChecksAgentToAgentId IS NULL)
  UNION ALL
  --Provider commission 
  SELECT NULL CheckElsId
  , NULL ReturnPaymentsId
  , [dbo].[ProviderCommissionPayments].ProviderCommissionPaymentId
  , NULL OtherCommissionId
  , NULL AS ProviderTypeId
  , [dbo].[ProviderCommissionPayments].Usd AS Amount
  , CreationDate
  , CreatedBy
  , AgencyId
  , [dbo].[ProviderCommissionPayments].ValidatedOn
  , [dbo].[ProviderCommissionPayments].ValidatedBy
  , 'P' AS CheckType
  , NULL AS CashierId
  , UPPER(Users1.Name) AS CreatedByName
  , 0 Fee
  --   , [dbo].[ProviderCommissionPayments].CheckDate AS CheckDate
  , FORMAT([dbo].[ProviderCommissionPayments].CheckDate, 'MM-dd-yyyy', 'en-US') CheckDate
  , ProccesCheckReturned
  , NULL Routing
  , NULL Account
  , CheckNumber
  , 0 Discount
  , 0 TotalToPay
  , 0 FeePorcentage
  FROM [dbo].[ProviderCommissionPayments]
       INNER JOIN
       dbo.Users AS Users1
       ON [dbo].[ProviderCommissionPayments].CreatedBy = Users1.UserId

  WHERE
        --        (CAST(dbo.[ProviderCommissionPayments].CreationDate AS DATE) = CAST(@Date AS DATE) OR @Date IS NULL)
        [dbo].[ProviderCommissionPayments].[ValidatedBy] = @UserId AND
        ([ProviderCommissionPayments].LotNumber = @LotNumber OR
        @LotNumber IS NULL) AND
        ([ProviderCommissionPayments].PaymentChecksAgentToAgentId = @PaymentChecksAgentToAgentId OR
        @PaymentChecksAgentToAgentId IS NULL)

  UNION ALL
  SELECT NULL AS CheckElsId
  , NULL ReturnPaymentsId
  , [dbo].[ProviderCommissionPayments].ProviderCommissionPaymentId
  , O.OtherCommissionId
  , NULL AS ProviderTypeId
  , O.Usd AS Amount
  , CreationDate
  , CreatedBy
  , AgencyId
  , [dbo].[ProviderCommissionPayments].ValidatedOn
  , [dbo].[ProviderCommissionPayments].ValidatedBy
  , 'O' AS CheckType
  , NULL AS CashierId
  , UPPER(Users1.Name) AS CreatedByName
  , 0 Fee
  --   ,O.CheckDate CheckDate
  , FORMAT(O.CheckDate, 'MM-dd-yyyy', 'en-US') CheckDate
  , O.ProccesCheckReturned
  , NULL Routing
  , NULL Account
  , O.CheckNumber
  , 0 Discount
  , 0 TotalToPay
  , 0 FeePorcentage
  FROM [dbo].[ProviderCommissionPayments]
       INNER JOIN
       dbo.Users AS Users1
       ON [dbo].[ProviderCommissionPayments].CreatedBy = Users1.UserId
       INNER JOIN
       [dbo].[OtherCommissions] O
       ON [dbo].[ProviderCommissionPayments].ProviderCommissionPaymentId = O.ProviderCommissionPaymentId

  WHERE
        -- (CAST(O.CheckDate AS DATE) = CAST(@Date AS DATE) OR @Date IS NULL)
        O.[ValidatedBy] = @UserId AND
        (O.LotNumber = @LotNumber OR
        @LotNumber IS NULL) AND
        (O.PaymentChecksAgentToAgentId = @PaymentChecksAgentToAgentId OR
        @PaymentChecksAgentToAgentId IS NULL)

END

GO