SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[sp_DeleteElsManualOtherById](@OtherId INT)
AS
     BEGIN
         DELETE FROM ElsManualOther
         WHERE OtherId = @OtherId;
        
     END;
GO