SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--LASTUPDATEDBY: JOHAN
--LASTUPDATEDON:5-12-2023
--CAMBIOS EN 5355, Guarda informacion de pagos de missing
CREATE PROCEDURE [dbo].[sp_SaveMissingPayment] (@OtherPaymentId INT = NULL,
@DailyId INT,
@PayMissing BIT,
@AgencyId INT,
@CreatedBy INT,
@CreationDate DATETIME,
--@IdCreated INT OUTPUT,
@LastUpdatedBy INT,
@LastUpdatedOn DATETIME,
@UsdMissing DECIMAL(18, 2) = NULL,
@UsdPayMissing DECIMAL(18, 2))
AS
BEGIN

  DECLARE @MissingValue DECIMAL(18, 2);
  DECLARE @MissingPayments DECIMAL(18, 2) ;
  DECLARE @OldMissingPayments DECIMAL(18, 2) ;
  DECLARE @MissingPaymentsWithoutCurrentPayment DECIMAL(18, 2);


  --VALOR DEL MISSING QUE ESTOY PAGANDO
  SET @MissingValue = (SELECT
      ABS(Missing)
    FROM dbo.Daily d
    WHERE d.DailyId = @DailyId)


  --PAGOS EFECTUADOS TOTAL
  SET @MissingPayments = (SELECT
      SUM(op.UsdPayMissing)
    FROM dbo.OtherPayments op
    WHERE op.DailyId = @DailyId
    AND ( OtherPaymentId <> @OtherPaymentId OR @OtherPaymentId is NULL )
    AND CAST(op.PayMissing AS BIT) = 1)



  IF ((@MissingPayments + @UsdPayMissing > @MissingValue)) --PAGOS NUEVOS
  BEGIN
    SELECT
      -1
  END
  ELSE
  IF (@OtherPaymentId IS NULL)
  BEGIN
    INSERT INTO [dbo].[OtherPayments] (Description,
    Usd,
    CardPayment,
    CardPaymentFee,
    AgencyId,
    CreatedBy,
    CreationDate,
    LastUpdatedBy,
    LastUpdatedOn,
    Cash,
    PayMissing,
    UsdMissing,
    UsdPayMissing,
    DailyId)
      VALUES (NULL, NULL, 0, NULL, @AgencyId, @CreatedBy, @CreationDate, @LastUpdatedBy, @LastUpdatedOn, NULL, @PayMissing, @UsdMissing, @UsdPayMissing, @DailyId);
--    SET @IdCreated = @@identity;
SELECT @@identity
  END;
  ELSE

    DECLARE @TotalCurretPayments DECIMAL(18, 2) = 0;

  -- PAGO DETALLADO SI SE ESTA EDITANDO
  SET @OldMissingPayments = (SELECT TOP 1
      op.UsdPayMissing
    FROM dbo.OtherPayments op
    WHERE op.OtherPaymentId = @OtherPaymentId
    AND CAST(op.PayMissing AS BIT) = 1)

  --PAGOS SIN SELECCIONAR EL QUE ESTOY EVALUANDO AL GUARDAR
  SET @MissingPaymentsWithoutCurrentPayment = (SELECT
      SUM(op.UsdPayMissing)
    FROM dbo.OtherPayments op
    WHERE op.DailyId = @DailyId
    AND op.OtherPaymentId != @OtherPaymentId
    AND CAST(op.PayMissing AS BIT) = 1)

  -- SI EL PAGO EN LA SUMATORIA ES MAYOR AL DAILY 
  SET @TotalCurretPayments = @MissingPaymentsWithoutCurrentPayment + @UsdPayMissing;
  IF (@UsdPayMissing != @OldMissingPayments
    AND ((@UsdPayMissing > @MissingValue)
    OR (@TotalCurretPayments > @MissingValue)))
  BEGIN
    SELECT
      -1
  END
  ELSE
  BEGIN
    UPDATE [dbo].[OtherPayments]
    SET LastUpdatedBy = @LastUpdatedBy
       ,LastUpdatedOn = @LastUpdatedOn
       ,UsdPayMissing = @UsdPayMissing
    WHERE OtherPaymentId = @OtherPaymentId;
--    SET @IdCreated = @OtherPaymentId;
SELECT @OtherPaymentId
  END;
END;


GO