SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetCommisinCardFeeDebitSettings]
AS
     BEGIN
         SELECT *
         FROM ComisionCardFeeDebitSetting;
     END;
GO