SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetComissionSettings]
AS
     BEGIN
         SELECT TOP 1 *
         FROM ComissionSettings;
     END;

GO