SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAProvidersElsWithProviderCommissionPayment] @Creationdate DATE = NULL,
@AgencyId INT = NULL,
@ProviderElsId INT = NULL
AS
BEGIN
  DECLARE @MonthDate INT = CAST(MONTH(@Creationdate) AS INT);
  DECLARE @YearDate INT = CAST(YEAR(@Creationdate) AS INT);
  SELECT
    p.ProviderElsId
   ,p.Code
   ,p.Name
   ,p.AllowFee1Default
   ,p.Fee1Default
   ,p.AllowFee2
   ,p.AllowDefaultUsd
   ,p.DefaultUsd
   ,ISNULL(F.PlateStickerFee2Id, 0) PlateStickerFee2Id
   ,ISNULL(p.FeeCollect, 0) AS FeeCollect
   ,ISNULL(F.Usd, 0) Fee2DefaultUsd
   ,ISNULL(F.UsdLessEqualValue, 0) UsdLessEqualValue
   ,ISNULL(F.UsdGreaterValue, 0) UsdGreaterValue
   ,ISNULL(F.Usd, 0) Usd
   ,ISNULL(FeeELS, 0) AS FeeELS
   ,ISNULL(FeeELSTrp, 0) AS FeeELSTrp
   ,(ISNULL((SELECT TOP 1
        ISNULL(pc.ProviderCommissionPaymentId, 0) ProviderCommissionPaymentId
      FROM Providers p
      INNER JOIN ProviderTypes pt
        ON p.ProviderTypeId = pt.ProviderTypeId
        --AND P.Active = 1
        AND pt.Code = 'C05'
      INNER JOIN ProviderCommissionPayments pc
        ON pc.ProviderId = p.ProviderId
        AND (pc.Year = @YearDate
        AND pc.Month = @MonthDate)
        AND pc.AgencyId = @AgencyId)
    , 0)) AS ProviderElsCommissionPaymentId
   ,(ISNULL((SELECT TOP 1
        ISNULL(pc.ProviderCommissionPaymentId, 0) ProviderCommissionPaymentId
      FROM Providers p
      INNER JOIN ProviderTypes pt
        ON p.ProviderTypeId = pt.ProviderTypeId
        --AND P.Active = 1
        AND pt.Code = 'C09'
      INNER JOIN ProviderCommissionPayments pc
        ON pc.ProviderId = p.ProviderId
        AND (pc.Year = @YearDate
        AND pc.Month = @MonthDate)
        AND pc.AgencyId = @AgencyId)
    , 0)) AS ProviderTrpCommissionPaymentId
  FROM dbo.ProvidersEls p
  LEFT JOIN PlateStickersFee2 F
    ON p.ProviderElsId = F.ProviderElsId
  WHERE p.ProviderElsId = @ProviderElsId
  OR @ProviderElsId IS NULL
  ORDER BY Name;
END;
GO