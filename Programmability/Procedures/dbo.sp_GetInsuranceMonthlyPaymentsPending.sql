SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      JF
-- Create date: 9/12/2024 8:48 a. m.
-- Database:    developing
-- Description: task 6423 Insurance - Add nuevo campo insurance
-- =============================================

CREATE PROCEDURE [dbo].[sp_GetInsuranceMonthlyPaymentsPending] @UserId INT = NULL, @AgencyId INT = NULL
AS

BEGIN

  SELECT
    *
  FROM dbo.[FN_GetInsuranceMonthlyPaymentsPending](@UserId, @AgencyId)


END



GO