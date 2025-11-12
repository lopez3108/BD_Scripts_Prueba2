SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteOtherService](@OtherId INT)
AS
     BEGIN
         DELETE OthersServices
         WHERE OtherId = @OtherId;
	    SELECT 1;
     END;


GO