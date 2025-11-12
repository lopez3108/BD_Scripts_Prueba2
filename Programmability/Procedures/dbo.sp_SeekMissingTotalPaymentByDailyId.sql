SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:09-12-2023
--CAMBIOS EN 5355, Verifica si un pago de missing fue realizado en totalidad.
CREATE PROCEDURE [dbo].[sp_SeekMissingTotalPaymentByDailyId] @DailyId INT
AS
BEGIN
  DECLARE @MissingValue DECIMAL(18, 2) = 0;
  DECLARE @MissingPayments DECIMAL(18, 2) = 0;
  DECLARE @hasMissingPayment BIT = 0;

  SET @MissingValue = (SELECT
     abs(Missing) 
    FROM dbo.Daily d
    WHERE d.dailyId = @DailyId)
    
    SET @MissingPayments = (SELECT
      SUM(op.usdPayMissing)
    FROM dbo.OtherPayments op
    WHERE op.dailyId = @DailyId)

  IF (@MissingPayments >= @MissingValue )
  BEGIN
    SET @hasMissingPayment = 1
  END


  SELECT
    @hasMissingPayment

END




GO