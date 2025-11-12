SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2024-10-02 JT/6039: (Add new filter DateTo)

-- 2024-08-31 DJ/6016: Gets the daily cashier insurance registrations

CREATE PROCEDURE [dbo].[sp_GetInsuranceRegistrationsDailyCashier] @UserId INT = NULL,
@AgencyId INT,
@Date DATETIME
AS

BEGIN

  SELECT
    *
  FROM dbo.[FN_GetInsuranceRegistration](@AgencyId, @UserId, @Date,@Date)




END


GO