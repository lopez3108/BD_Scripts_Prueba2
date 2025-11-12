SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- date 06/08/2025 task 6665 JF  Nuevo campo MID serial number para los Agencies 

CREATE PROCEDURE [dbo].[sp_DeleteMidSerialsByAgency] @MidSerialsByAgencyId INT,
@AgencyId INT = NULL,
@AgencyLastUpdatedBy INT = NULL,
@AgencyLastUpdatedOn DATETIME = NULL
AS
BEGIN
  SET NOCOUNT ON;

  -- Eliminar el serial
  DELETE FROM dbo.MidSerialsByAgency
  WHERE MidSerialsByAgencyId = @MidSerialsByAgencyId;

  -- Actualizar los campos de auditoría en la agencia en relalcion 
  UPDATE dbo.Agencies
  SET AgencyLastUpdatedBy = @AgencyLastUpdatedBy
     ,AgencyLastUpdatedOn = @AgencyLastUpdatedOn
  WHERE AgencyId = @AgencyId;

  SELECT
    1;
END
GO