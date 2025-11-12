SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveTraining]
(@TrainingId   INT            = NULL,
 @CycleDate   DATETIME,
 @CreationDate   DATETIME,
 @DaysToCompleteStatusId   INT,
 @DocumentName  VARCHAR(400),   
 @LastUpdatedOn   DATETIME,
 @LastUpdatedBy  INT     ,
 @CreatedBy  INT     ,
 @TrainingName  VARCHAR(170),
 @Status  INT,
 @IsRequired BIT,
 @ApplyToAdmin BIT  = NULL,
 @ApplyToCashier BIT = NULL,
 @ApplyToManager BIT  = NULL,
 @IdCreated      INT OUTPUT
)
AS
     BEGIN
        IF(@TrainingId IS NULL)
             BEGIN
			 
			 ----Preguntamos si el la fecha de ciclo es menor a la fecha de creación y de ser así, entonces debemos aumentar un año a la fecha del ciclo
				-- DECLARE @CreationDateFirstDay AS DATETIME = DATEFROMPARTS ( year(@CreationDate), month(@CreationDate), 1 )  
				-- IF(@CycleDate < @CreationDateFirstDay)
				-- BEGIN
				--SET @CycleDate = DATEADD(YEAR,1,@CycleDate);
				-- END
                 INSERT INTO [dbo].Training
                 (
				 CreationDate,
				 TrainingName,
				 CycleDate,
				 Status,
				 IsRequired,
				  DaysToCompleteStatusId,
                  DocumentName,
				  CreatedBy,
                  LastUpdatedOn,
				  LastUpdatedBy,
				  ApplyToAdmin,
				  ApplyToCashier,
				  ApplyToManager
                 
                 )
                 VALUES
                 (@CreationDate,
				 @TrainingName,
				 @CycleDate ,
				 @Status,
				 @IsRequired,
				 @DaysToCompleteStatusId,
				 @DocumentName ,
				 @CreatedBy,
				 @LastUpdatedOn ,
				 @LastUpdatedBy,
				 @ApplyToAdmin,
				 @ApplyToCashier,
				 @ApplyToManager
                 );
				   SET @IdCreated = @@IDENTITY;
         END;
             ELSE
             BEGIN
			

                 UPDATE [dbo].Training
                   SET
					  
					  TrainingName = @TrainingName,
					  CycleDate = @CycleDate ,
					  Status = @Status,
					  IsRequired = @IsRequired,
					  DaysToCompleteStatusId= @DaysToCompleteStatusId,                 
					  DocumentName= @DocumentName,
					  LastUpdatedOn= @LastUpdatedOn,
					  LastUpdatedBy= @LastUpdatedBy,
					  ApplyToAdmin= @ApplyToAdmin,
					  ApplyToCashier= @ApplyToCashier,
				      ApplyToManager= @ApplyToManager
                 WHERE TrainingId = @TrainingId;
				   SET @IdCreated = @TrainingId;
				   
         END;
     END;
GO