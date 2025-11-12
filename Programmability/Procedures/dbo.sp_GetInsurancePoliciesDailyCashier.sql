SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2024-10-02 JT/6039: (Add new filter DateTo)

-- 2024-08-27 DJ/6016: Gets the daily cashier new policies

CREATE PROCEDURE [dbo].[sp_GetInsurancePoliciesDailyCashier] @UserId INT = NULL,
@AgencyId INT,
@Date DATETIME
AS

BEGIN

  SELECT
    *
  FROM dbo.[FN_GetInsurancePolicies](@AgencyId, @UserId, @Date,@Date)




END


GO