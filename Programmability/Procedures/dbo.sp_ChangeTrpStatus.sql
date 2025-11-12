SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_ChangeTrpStatus]
(
                 @TRPId int = NULL, 
                 @UpdatedBy int = NULL, 
                 @UpdatedOn datetime = NULL, 
                 @PaymentDate datetime = NULL, 
                 @Paid bit = NULL, 
                 @PaidBy int = NULL

)
AS
BEGIN
  UPDATE [dbo].TRP
    SET 
   
    PaymentDate = @PaymentDate,
    UpdatedBy = @UpdatedBy,
    UpdatedOn = @UpdatedOn,
    PaidBy = @PaidBy, 
    Paid = @Paid
  WHERE TRPId = @TRPId;
END;
GO