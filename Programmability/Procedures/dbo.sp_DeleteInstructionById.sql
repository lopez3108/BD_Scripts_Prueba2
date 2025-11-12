SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteInstructionById](@InstructionChangeId INT)
AS
     BEGIN
         DELETE InstructionChange
         WHERE InstructionChangeId = @InstructionChangeId; 
     END;
GO