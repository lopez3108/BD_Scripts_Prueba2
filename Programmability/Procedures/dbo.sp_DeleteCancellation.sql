SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteCancellation](@CancellationId INT)
AS
     BEGIN
         DELETE Cancellations
         WHERE CancellationId = @CancellationId;
         SELECT 1;
     END;


GO