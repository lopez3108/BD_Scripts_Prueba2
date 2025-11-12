SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-04-21 DJ/6466: Seleccionar razón de insunrace completada

CREATE PROCEDURE [dbo].[sp_GetInsuranceQuoteCompleteReason] 
AS
BEGIN


SELECT i.[InsuranceQuoteCompleteReasonId]
      ,i.[Description]
      ,i.[Code]
  FROM [dbo].[InsuranceQuoteCompleteReason] i
 



END
GO