SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetCommisinPhoneCardsSettings]
AS
     BEGIN
         SELECT TOP 1 *
         FROM CommisinPhoneCardsSetting;
     END;
GO