SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPropertiesForPropertyControl]
AS
  SELECT
    p.PropertiesId AS PropertiesId
  FROM Properties p
GO