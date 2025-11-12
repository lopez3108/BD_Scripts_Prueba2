SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- date 04/08/2025 task 6665   Nuevo campo MID serial number para los Agencies 
-- date 07/08/2025 task 6707 JF Agregar columnas Created by y Creation date en la funcionalidad MID serial numbers

CREATE PROCEDURE [dbo].[sp_GetMidSerialByAgency] @AgencyId INT = NULL
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    FORMAT(CreatedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreatedOnFormat
   ,u.Name CreatedByName
   ,*

  FROM MidSerialsByAgency msba
  LEFT JOIN Users u
    ON msba.CreatedBy = u.UserId
  WHERE AgencyId = @AgencyId
  ORDER BY msba.MidSerialsByAgencyId ASC
END


GO