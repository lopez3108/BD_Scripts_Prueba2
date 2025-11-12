SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllNotesLendify] @LendifyId INT = NULL
AS
     BEGIN
         SELECT LendifyNotesId,
                LendifyId,
                Note,
                CreationDate,
                CreatedBy,
                Name AS CreatedByName
         FROM [dbo].lendifyNotes
              INNER JOIN Users ON [dbo].[LendifyNotes].CreatedBy = Users.UserId
         WHERE LendifyId = @LendifyId
         ORDER BY CreationDate;
     END;

	 select * from lendifyNotes
GO