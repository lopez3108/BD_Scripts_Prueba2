SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		David Jaramillo
-- Description:	Retorna los pagos de un cheque retornado
-- =============================================
-- =============================================
-- Author:      JF
-- Create date: 25/08/2024 5:07 p. m.
-- Database:    developing
-- Description: 5753 Lista de pagos retornos debe llevar last updated by y on
-- =============================================

CREATE PROCEDURE [dbo].[sp_GetReturnPayments] @ReturnedCheckId INT
AS
BEGIN
  SELECT
    dbo.ReturnPayments.ReturnPaymentsId
   ,dbo.ReturnPayments.ReturnedCheckId
   ,dbo.ReturnPayments.Usd
   ,dbo.ReturnPayments.Cash
   ,ISNULL(ISNULL(dbo.ReturnPayments.Cash, 0) - ISNULL(dbo.ReturnPayments.Usd, 0), 0) Change
   ,dbo.ReturnPayments.CreationDate
   ,dbo.ReturnPayments.CreatedBy
   ,dbo.ReturnPaymentMode.ReturnPaymentModeId
   ,dbo.ReturnPaymentMode.Description AS PaymentMode
   ,dbo.Users.Name AS CreatedByName
   ,dbo.ReturnPayments.CheckNumber
   ,dbo.ReturnPayments.CardPayment
   ,dbo.ReturnPayments.CardPaymentFee
   ,dbo.ReturnPayments.CheckDate
   ,dbo.Users.Name AS LastUpdatedByName
   ,FORMAT(dbo.ReturnPayments.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') LastUpdatedOnFormat
   ,a.Code +'-'+ a.Name AS Agency
   ,
    --((dbo.ReturnedCheck.USD + ISNULL(dbo.ReturnedCheck.Fee,0))
    ([dbo].[fn_CalculateTotalReturned](dbo.ReturnedCheck.ReturnedCheckId) - dbo.fn_CalculatePaidReturnedByDate(dbo.ReturnPayments.ReturnedCheckId, dbo.ReturnPayments.CreationDate)) AS Balance
  FROM dbo.ReturnPayments
  INNER JOIN dbo.ReturnPaymentMode
    ON dbo.ReturnPayments.ReturnPaymentModeId = dbo.ReturnPaymentMode.ReturnPaymentModeId
  INNER JOIN dbo.Users
    ON dbo.ReturnPayments.CreatedBy = dbo.Users.UserId
  INNER JOIN dbo.ReturnedCheck
    ON dbo.ReturnedCheck.ReturnedCheckId = dbo.ReturnPayments.ReturnedCheckId
    INNER JOIN dbo.Agencies a ON ReturnPayments.AgencyId = a.AgencyId
  WHERE dbo.ReturnPayments.[ReturnedCheckId] = @ReturnedCheckId
  ORDER BY dbo.ReturnPayments.CreationDate ASC;
END;

GO