SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:      JF
-- Create date: 9/06/2024 7:41 p. m.
-- Database:    devtest
-- Description: Task 5895 Nueva alerta QA OTHER PAYMENTS (PENDING)
-- =============================================


CREATE PROCEDURE [dbo].[sp_GetCompleteOtherPayment]  @OtherPaymentId INT = NULL
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
  WHERE ISNULL(op.completed, 0) = 1 AND op.OtherPaymentId = @OtherPaymentId
END


GO