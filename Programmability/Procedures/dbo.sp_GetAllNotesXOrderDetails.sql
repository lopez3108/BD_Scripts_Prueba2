SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllNotesXOrderDetails] @OrderOfficeSupplieId INT
AS
     SELECT NoteXOrderSupplyId, 
            nx.Note, 
            nx.CreationDate, 
            u.Name CreatedByName
     FROM NotesXOrderOfficeSupply nx
          JOIN Users u ON u.UserId = nx.CreatedBy
     WHERE nx.OrderOfficeSupplieId = @OrderOfficeSupplieId
     ORDER BY CreationDate ASC;
GO