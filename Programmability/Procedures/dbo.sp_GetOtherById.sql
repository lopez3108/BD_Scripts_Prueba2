SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetOtherById](@OtherId INT)
AS
     BEGIN
         SELECT OtherId,
                Name,
                AcceptNegative,
                AcceptDetails,
				Active
         FROM OthersServices
         WHERE OtherId = @OtherId
     END;
GO