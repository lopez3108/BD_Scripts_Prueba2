SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- Date 29-05-2025 task 6542 Permitir eliminar discounts   JF

CREATE PROCEDURE [dbo].[sp_DeletePromotionalCodeById] (@PromotionalCodeStatusId INT)
AS
BEGIN

  DELETE PromotionalCodesStatus
  WHERE PromotionalCodeStatusId = @PromotionalCodeStatusId

END;

GO