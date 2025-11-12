SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create PROCEDURE [dbo].[sp_DeleteNotary](@NotaryId INT)
AS
     BEGIN
         DELETE FROM [dbo].Notary
         WHERE NotaryId = @NotaryId;
     END;
GO