SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetCommisionHeadphonesAndChargersSettings]
AS
     BEGIN
         SELECT TOP 1 *
         FROM ComissionHeadphonesAndChargersSettings;
     END;
GO