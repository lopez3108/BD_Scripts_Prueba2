SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		Romario Jimenez
-- Description:	Retorna los pagos retornado
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetAllReturnPayments] @AgencyId INT,
@UserId INT,
@Date DATETIME
AS
BEGIN
  SELECT
    dbo.ReturnPayments.ReturnPaymentsId
   ,dbo.ReturnPayments.ReturnedCheckId
   ,dbo.ReturnPayments.USD
   ,dbo.ReturnPayments.Cash
   ,ISNULL(ISNULL(dbo.ReturnPayments.Cash, 0) - ISNULL(dbo.ReturnPayments.USD, 0), 0) Change
   ,dbo.ReturnPayments.CreationDate
   ,dbo.ReturnPayments.CreatedBy
   ,dbo.ReturnPaymentMode.ReturnPaymentModeId
   ,dbo.ReturnPaymentMode.Description AS PaymentMode
   ,dbo.Users.Name AS CreatedByName
   ,dbo.ReturnPayments.CheckNumber
   ,dbo.ReturnPayments.CardPayment
   ,dbo.ReturnPayments.CardPaymentFee
   ,dbo.ReturnPayments.CheckDate
   ,u.Name AS ClientName
   ,ReturnedCheck.CheckNumber CheckNumberRetorno
   ,dbo.ReturnPaymentMode.Code
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
    INNER JOIN dbo.Clientes c ON ReturnedCheck.ClientId = c.ClienteId
    INNER JOIN users u ON c.UsuarioId = u.UserId
  WHERE dbo.ReturnPayments.[AgencyId] = @AgencyId
  AND dbo.Users.UserId = @UserId AND CAST(dbo.ReturnPayments.CreationDate as DATE) = CAST(@Date as DATE)
  ORDER BY dbo.ReturnPayments.CreationDate ASC;
END;

GO