SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_SaveCheckListResult] (@TitleId INT = NULL,
@TRPId INT = NULL,

@CreatedBy INT,
@CreationDate DATETIME,
@CheckListId INT, @LabelEN VARCHAR(100), @LabelES VARCHAR(100))
AS
BEGIN
  INSERT INTO  [dbo].[CheckListResult] (TitleId,
  TRPId,
  CreatedBy,
  CreationDate,
  CheckListId, LabelEN, LabelES)
    VALUES (@TitleId, @TRPId, @CreatedBy, @CreationDate, @CheckListId, @LabelEN, @LabelES);
END;








GO