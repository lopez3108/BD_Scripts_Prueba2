SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[sp_GetAllNotesXInstruction] @InstructionChangeId INT
AS
     SELECT NoteXInstructionId, 
            nx.Note, 
            nx.CreationDate, 
            u.Name CreatedByName
     FROM NotesXInstructionChange nx
          JOIN Users u ON u.UserId = nx.CreatedBy
     WHERE nx.InstructionChangeId = @InstructionChangeId
     ORDER BY CreationDate ASC;
GO