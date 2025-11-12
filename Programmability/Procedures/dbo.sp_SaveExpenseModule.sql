SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-10-31 JF/ 6815 Completar varios expenses daily

CREATE PROCEDURE [dbo].[sp_SaveExpenseModule] 
  @ExpenseId INT = NULL,
  @ExpenseTypeId INT = NULL,
  @ExpenseTypeCode VARCHAR(10) = NULL,
  @Validated BIT = NULL,
  @ValidatedBy INT = NULL,
  @IdCreated INT OUTPUT,
  @ValidatedOn DATETIME = NULL
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @AlreadyValidated BIT;

  -- Obtener el estado actual de validación
  SELECT TOP 1 
    @AlreadyValidated = e.Validated
  FROM Expenses e
  WHERE e.ExpenseId = @ExpenseId;

  -- Si ya está validado, retornamos -1
IF (@AlreadyValidated = 1)
BEGIN
    SET @IdCreated = -1;  -- asegurar valor numérico
    RETURN;
END;

  -- Obtener el ID del tipo de gasto según el código
  SELECT 
    @ExpenseTypeId = ExpensesTypeId
  FROM ExpensesType
  WHERE Code = @ExpenseTypeCode;

  -- Actualizar el registro
  UPDATE dbo.Expenses
  SET ExpenseTypeId = @ExpenseTypeId,
      Validated = @Validated,
      ValidatedBy = @ValidatedBy,
      ValidatedOn = @ValidatedOn
  WHERE ExpenseId = @ExpenseId;

  SET @IdCreated = @ExpenseId;

  SELECT 1 AS Result; -- operación exitosa
END;
GO