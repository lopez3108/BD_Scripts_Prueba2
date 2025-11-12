SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetComisionReturnedChecksSettings]
AS
     BEGIN
         SELECT TOP 1 *
         FROM ComisionReturnedChecksSettings;
     END;
GO