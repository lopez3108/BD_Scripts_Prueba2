SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      JF
-- Create date: 9/06/2024 4:53 p. m.
-- Database:    devtest
-- Description: task 5895 Nueva alerta QA OTHER PAYMENTS (PENDING)
-- =============================================

CREATE PROCEDURE [dbo].[sp_GetAllOtherPaymentIncomplete]
AS
BEGIN
  SELECT  
   op.OtherPaymentId  
   ,FORMAT(op.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US')	CreationDate   
   ,a.Code + '-' + a.Name AS agency
   ,u.Name cashier
   ,op.Description
   ,op.Usd
  FROM OtherPayments op
    INNER JOIN Agencies a ON op.AgencyId = a.AgencyId
    INNER JOIN Users u ON op.CreatedBy = u.UserId
  WHERE ISNULL(op.completed, 0) = 0 AND  ISNULL(op.PayMissing,0) = 0

END
GO