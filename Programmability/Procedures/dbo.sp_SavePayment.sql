SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SavePayment]
(@PaymentId      INT            = NULL,
 @FinancingId    INT            = NULL,
 @Usd            DECIMAL(18, 2)  = NULL,
 @CreatedBy      INT            = NULL,
 @CreatedOn      DATETIME       = NULL,
 @CardPayment    BIT,
 @CardPaymentFee INT            = NULL,
 @Response       INT OUTPUT
)
AS
     DECLARE @StatusId INT;
     DECLARE @UsdFinancing DECIMAL(18, 2);
     SET @UsdFinancing =
     (
         SELECT Usd
         FROM Financing
         WHERE FinancingId = @FinancingId
     );
     DECLARE @UsdAllPaymentsFinancing DECIMAL(18, 2);
     SET @UsdAllPaymentsFinancing =
     (
         SELECT SUM(Usd)
         FROM Payments
         WHERE FinancingId = @FinancingId
     );
     DECLARE @SumPayments DECIMAL(18, 2);
     SET @SumPayments = ISNULL(@UsdAllPaymentsFinancing, 0) + @Usd;
     IF(@SumPayments <= @UsdFinancing)
         BEGIN
             IF(@UsdFinancing = @SumPayments)
                 BEGIN
                     SET @Response = 3; --financiación completada
                     SET @StatusId =
                     (
                         SELECT FinancingStatusId
                         FROM FinancingStatus
                         WHERE CODE = 'C02'
                     );
					--Actualizamos la financiación a estado completada
                     UPDATE Financing
                       SET
                           CompletedBy = @CreatedBy,
                           CompletedOn = @CreatedOn,
                           FinancingStatusId = @StatusId
                     WHERE FinancingId = @FinancingId;
             END;
                 ELSE
                 BEGIN
                     SET @Response = 1; --Pago ok
             END;
             IF(@PaymentId IS NULL)
                 BEGIN
                     INSERT INTO [dbo].Payments
                     (FinancingId,
                      USD,
                      CreatedBy,
                      CreatedOn,
                      CardPayment,
                      CardPaymentFee
                     )
                     VALUES
                     (@FinancingId,
                      @Usd,
                      @CreatedBy,
                      @CreatedOn,
                      @CardPayment,
                      @CardPaymentFee
                     );
             END;
                 ELSE
                 BEGIN
                     UPDATE [dbo].Payments
                       SET
                           USD = @Usd,
					  CardPayment = @CardPayment,
                           CardPaymentFee = @CardPaymentFee
                     WHERE PaymentId = @PaymentId;
             END;
     END;
         ELSE
         BEGIN
             SET @Response = 2; --Pago supera la financiación
     END;
GO