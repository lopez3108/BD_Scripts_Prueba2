SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetCommisionVentraSettings]
AS
     BEGIN
         SELECT TOP 1 *
         FROM CommisionVentraSetting;
     END;
GO