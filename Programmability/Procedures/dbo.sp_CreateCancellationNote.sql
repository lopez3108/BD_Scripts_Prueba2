SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreateCancellationNote] 
(
@NoteXCancellationId INT = NULL,
@Description         VARCHAR(300),
@CreationDate        DATETIME  = NULL,
@CreatedBy           INT = NULL,
@UpdatedOn           DATETIME  = NULL,
@UpdatedBy           INT = NULL

)
AS

BEGIN

  IF (@NoteXCancellationId IS NULL
    OR @NoteXCancellationId = 0)
  BEGIN

    --    IF (EXISTS (SELECT
    --          NoteXCancellationId
    --        FROM NotesXCancellations
    --        WHERE Description = @Description)
    --      )
    --    BEGIN
    --
    --      SELECT
    --        -1
    --
    --    END
    --    ELSE
    --    BEGIN


    INSERT INTO [dbo].[NotesxCancellations]

      (
      [Description],
      CreationDate,
      CreatedBy
      )

      VALUES 
      (
      @Description,
      @CreationDate,
      @CreatedBy   
      )

    SELECT
      @@IDENTITY

  END
  ELSE
  BEGIN

    UPDATE [dbo].[NotesxCancellations]
    SET
     [Description] = @Description,
     CreationDate  = @CreationDate,
     CreatedBy     = @CreatedBy,
     UpdatedOn    = @UpdatedOn,
     UpdatedBy     = @UpdatedBy

    WHERE NoteXCancellationId = @NoteXCancellationId

    SELECT
      @NoteXCancellationId


  END







END
GO