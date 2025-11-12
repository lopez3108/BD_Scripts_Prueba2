SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteProviderEls](@ProviderElsId INT)
AS
     BEGIN
         DELETE ProviderseLS
         WHERE ProviderElsId = @ProviderElsId;
         SELECT 1;
     END;


GO