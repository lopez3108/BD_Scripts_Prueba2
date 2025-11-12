SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- Date 11-06-2025 task 6570 Recalcular valores al eliminar descuento en las partes donde apliquen del Daily  JF

CREATE PROCEDURE [dbo].[sp_GetPromotionalCodeById] @Id INT,
@CodeType VARCHAR(10) = NULL
AS
BEGIN
  DECLARE @PromotionalCodeStatusId INT

  IF @CodeType = 'C01'
  BEGIN
    SELECT
      @PromotionalCodeStatusId = PromotionalCodeStatusId
    FROM PromotionalCodesStatus
    WHERE CheckId = @Id
  END
  ELSE
  IF @CodeType = 'C02'
  BEGIN
    SELECT
      @PromotionalCodeStatusId = PromotionalCodeStatusId
    FROM PromotionalCodesStatus
    WHERE CityStickerId = @Id
  END
  ELSE
  IF @CodeType = 'C03'
  BEGIN
    SELECT
      @PromotionalCodeStatusId = PromotionalCodeStatusId
    FROM PromotionalCodesStatus
    WHERE PlateStickerId = @Id
  END
  ELSE
  IF @CodeType = 'C04'
  BEGIN
    SELECT
      @PromotionalCodeStatusId = PromotionalCodeStatusId
    FROM PromotionalCodesStatus
    WHERE TitleId = @Id
  END

  -- Si no se encontró nada, devolver 0
  SELECT
    ISNULL(@PromotionalCodeStatusId, 0) AS PromotionalCodeStatusId

END;
GO