SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeletePromotionalCode](@PromotionalCodeId INT)
AS
     BEGIN
         IF NOT EXISTS
         (
             SELECT 1
             FROM PromotionalCodes
             WHERE PromotionalCodeId = @PromotionalCodeId
                   AND SentSMSDate = 1
         )
             BEGIN
                 DELETE PromotionalCodes
                 WHERE PromotionalCodeId = @PromotionalCodeId;
                 SELECT 'false' Retorno;
         END;
             ELSE
             BEGIN
                 SELECT  'true' Retorno;
         END;
     END;
GO