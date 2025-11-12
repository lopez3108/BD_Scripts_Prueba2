SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveTrainingXUser]
(@TrainingId   INT           ,
@UserId      INT,
@AgencyId INT ,
@TrainerId INT ,
@ComplianceOfficerId INT ,
@SignName VARCHAR(500),
@LastCompleteOn DATETIME,  
@IdCreated      INT  OUTPUT 
)
AS
     BEGIN

         --IF NOT EXISTS
         --(
         --    SELECT 1
         --    FROM TrainingXUsers
         --    WHERE TrainingId = @TrainingId and UserId= @UserId
         --)
         --    BEGIN
                 INSERT INTO  [dbo].TrainingXUsers
                 (TrainingId ,
				  UserId, 
				  AgencyId,
				  SignName,
				  LastCompleteOn,
				  ComplianceOfficerId,
				  TrainerId
                 )
                 VALUES
                 (@TrainingId,
				  @UserId, 
				  @AgencyId,
				  @SignName,
				  @LastCompleteOn,
				 @ComplianceOfficerId,
				 @TrainerId

                 );
				  SET @IdCreated = @@IDENTITY;
   --      END;
		 --ELSE 
		 --BEGIN 
		 -- UPDATE [dbo].TrainingXUsers
   --                SET
			--	   AgencyId=@AgencyId,
			--	  LastCompleteOn= @LastCompleteOn
				 
   --              WHERE UserId = @UserId;
			--SET  @IdCreated  = -1
		 --END;
             
     END;
GO