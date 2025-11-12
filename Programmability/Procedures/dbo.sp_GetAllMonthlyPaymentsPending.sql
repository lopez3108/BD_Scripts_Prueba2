SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      JF
-- Create date: 9/12/2024 8:48 a. m.
-- Database:    developing
-- Description: task 6423 Insurance - Add nuevo campo insurance
-- =============================================

CREATE PROCEDURE [dbo].[sp_GetAllMonthlyPaymentsPending] @UserId INT = NULL, @AgencyId INT = NULL

AS
BEGIN
  SELECT
    * 
  FROM dbo.InsuranceMonthlyPayment imp
  WHERE imp.MonthlyPaymentStatusId = 1
  AND (imp.CreatedBy = @UserId
  OR @UserId IS NULL)
  AND (imp.CreatedInAgencyId = @AgencyId
  OR @AgencyId IS NULL)

END;

GO