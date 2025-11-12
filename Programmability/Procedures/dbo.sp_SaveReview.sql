SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Last updated by JT/03-06-2025 Task 6649 Permitir administrar reviews externos
CREATE PROCEDURE [dbo].[sp_SaveReview] (@ReviewId INT = NULL,
@CycleDate DATETIME = NULL,
@CreationDate DATETIME,
@DaysToCompleteStatusId INT = NULL,
@DocumentName VARCHAR(400),
@LastUpdatedOn DATETIME,
@LastUpdatedBy INT,
@CreatedBy INT,
@ReviewName VARCHAR(170),
@Status INT,
@IsExternalReview BIT,
@ExpirationDateExternal DATE = NULL,
@IdCreated INT OUTPUT)
AS
BEGIN
  IF (@ReviewId IS NULL)
  BEGIN

    INSERT INTO [dbo].Reviews (CreationDate,
    ReviewName,
    CycleDate,
    Status,
    DaysToCompleteStatusId,
    DocumentName,
    CreatedBy,
    LastUpdatedOn,
    LastUpdatedBy,IsExternalReview, ExpirationDateExternal)
      VALUES (@CreationDate, @ReviewName, @CycleDate, @Status, @DaysToCompleteStatusId, @DocumentName, @CreatedBy, @LastUpdatedOn, @LastUpdatedBy,@IsExternalReview, @ExpirationDateExternal);
    SET @IdCreated = @@IDENTITY;
  END;
  ELSE
  BEGIN


    UPDATE [dbo].Reviews
    SET ReviewName = @ReviewName
       ,CycleDate = @CycleDate
       ,Status = @Status
       ,DaysToCompleteStatusId = @DaysToCompleteStatusId
       ,DocumentName = @DocumentName
       ,LastUpdatedOn = @LastUpdatedOn
       ,LastUpdatedBy = @LastUpdatedBy
       ,ExpirationDateExternal = @ExpirationDateExternal
    WHERE ReviewId = @ReviewId;
    SET @IdCreated = @ReviewId;

  END;
END;
GO