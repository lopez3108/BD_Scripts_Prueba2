SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- date 04/08/2025 task 6665 JF  Nuevo campo MID serial number para los Agencies 
-- date 07/08/2025 task 6707 JF Agregar columnas Created by y Creation date en la funcionalidad MID serial numbers

CREATE PROCEDURE [dbo].[sp_SaveMidSerialsByAgency] @MidSerialsByAgencyId INT = NULL,
@AgencyId INT,
@MidNumber VARCHAR(20),
@IsEdit BIT = NULL,
@AgencyLastUpdatedBy INT = NULL,
@AgencyLastUpdatedOn DATETIME = NULL,
@IdCreated INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  -- Solo validar límite si se va a insertar uno nuevo
  IF @MidSerialsByAgencyId IS NULL
  BEGIN
    -- Validación: máximo 15 seriales por agencia
    IF (SELECT
          COUNT(*)
        FROM dbo.MidSerialsByAgency
        WHERE AgencyId = @AgencyId)
      >= 15
    BEGIN

      SET @IdCreated = -1;
      RETURN;
    END;

    -- Insertar nuevo registro
    INSERT INTO dbo.MidSerialsByAgency (AgencyId, MidNumber,CreatedOn,CreatedBy)
      VALUES (@AgencyId, @MidNumber,@AgencyLastUpdatedOn,@AgencyLastUpdatedBy);

    SET @IdCreated = @@IDENTITY;
  END
  ELSE
  BEGIN
    -- Actualizar registro existente
    UPDATE dbo.MidSerialsByAgency
    SET AgencyId = @AgencyId
       ,MidNumber = @MidNumber
    WHERE MidSerialsByAgencyId = @MidSerialsByAgencyId;
  END


 -- Si es edición, actualizamos también la tabla de Agencies
  IF @IsEdit = 1
  BEGIN
    UPDATE dbo.Agencies
    SET AgencyLastUpdatedBy = @AgencyLastUpdatedBy,
        AgencyLastUpdatedOn = @AgencyLastUpdatedOn
    WHERE AgencyId = @AgencyId;
  END



  -- Retornar ID
  SELECT
    @MidSerialsByAgencyId AS MidSerialsByAgencyId;
END


GO