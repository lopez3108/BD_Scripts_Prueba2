SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveDailyAdjustment]
(@DailyAdjustmentId INT            = NULL,
 @DailyId           INT,
 @InitalMissing     DECIMAL(18, 2),
 @FinalMissing      DECIMAL(18, 2)  = NULL,
 @DifferenceMissing DECIMAL(18, 2)  = NULL,
 @CreationDate      DATETIME,
 @CreatedBy         INT
 --@IdCreated         INT OUTPUT
)
AS
     BEGIN
         IF(@DailyAdjustmentId IS NULL OR @DailyAdjustmentId = 0 )
             BEGIN
                 INSERT INTO [dbo].DailyAdjustments
                 (DailyId,
                  InitalMissing,
                  FinalMissing,
                  DifferenceMissing,
                  CreationDate,
                  CreatedBy
                 )
                 VALUES
                 (@DailyId,
                  @InitalMissing,
                  @FinalMissing,
                  @DifferenceMissing,
                  @CreationDate,
                  @CreatedBy
                 );
                 --SET @IdCreated = @@IDENTITY;
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].DailyAdjustments
                   SET
                       InitalMissing = @InitalMissing,
                       FinalMissing = @FinalMissing,
                       DifferenceMissing = @DifferenceMissing,
                       CreationDate = @CreationDate,
                       CreatedBy = @CreatedBy
                 WHERE DailyId = @DailyId;
                 --SET @IdCreated = @DailyId;
         END;
     END;
GO