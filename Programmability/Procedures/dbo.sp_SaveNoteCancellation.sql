SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveNoteCancellation] (@CancellationsNotesId INT = NULL,
@CancellationId INT = NULL,
@Note VARCHAR(300),
@CreatedBy INT,
@CreationDate DATETIME)
AS
BEGIN
  IF (@CancellationsNotesId IS NULL)
  BEGIN
    INSERT INTO [dbo].[CancellationNote] (Note,
    CreatedBy,
    CreationDate,
    CancellationId)
      VALUES (@Note, @CreatedBy, @CreationDate, @CancellationId);
  END;
  ELSE
  BEGIN
    UPDATE [dbo].[CancellationNote]
    SET Note = @Note
    WHERE CancellationsNotesId = @CancellationsNotesId;
  END;
END;
GO