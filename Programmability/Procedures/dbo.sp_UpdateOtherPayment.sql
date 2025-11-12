SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:      JF
-- Create date: 9/06/2024 8:03 p. m.
-- Database:    devtest
-- Description: Task 5895 Nueva alerta QA OTHER PAYMENTS (PENDING)
-- =============================================


CREATE PROCEDURE [dbo].[sp_UpdateOtherPayment]
@OtherPaymentId INT = NULL,
@CompletedBy INT = NULL,
@CompletedOn DATETIME = NULL

AS
BEGIN

  UPDATE OtherPayments
  SET completed = 1, CompletedBy = @CompletedBy,CompletedOn = @CompletedOn  WHERE OtherPaymentId = @OtherPaymentId
END
GO