SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-09-23 DJ/6020: Gets the daily insurance adjusment details
-- 2024-09-28 JT/6115: Gets ONLY the daily insurance adjusment details <> 0
-- 2025-01-27 DJ/6312: Insurance - Lo que se valida en el módulo de insurance no se está viendo reflejado en el Daily en el Adjustment
-- 2025-02-12 JT/6329: Fix error in calculated adjustment when is paid by ACH

CREATE PROCEDURE [dbo].[sp_GetInsuranceDailyAdjustment] @CreatedBy INT,
@Date DATETIME,
@AgencyId INT
AS

BEGIN


  SELECT
    *
   ,(ISNULL(f.USD, 0) + ISNULL(f.FeeService, 0) + ISNULL(f.CardFee, 0)) - ISNULL(f.FeeService, 0) - ISNULL(f.CardFee, 0) - ISNULL(f.CommissionUsd, 0) + ISNULL(f.ValidatedUSD, 0) AS Adjustment
  FROM [dbo].[FN_GetInsuranceDailyAdjustment](@AgencyId, @CreatedBy, @Date) f
  WHERE f.ValidatedUSD - f.USD <> 0


END
GO