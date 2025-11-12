SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveNotesXTitle]
(@TitleId   INT,
 @Note      VARCHAR(400),
 @CreatedBy INT,
 @CreatedOn DATETIME,
 @IsPrincipalNote bIT
)
AS
     BEGIN
         INSERT INTO [dbo].[NotesXTitles]
         (TitleId,
          Note,
          CreatedBy,
          CreatedOn,
		  IsPrincipalNote
         )
         VALUES
         (@TitleId,
          @Note,
          @CreatedBy,
          @CreatedOn,
		  @IsPrincipalNote
         );
     END;

                 
         
        

GO