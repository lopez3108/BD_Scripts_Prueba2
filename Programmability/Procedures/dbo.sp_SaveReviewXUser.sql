SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveReviewXUser]
(@ReviewId   INT           ,
 @UserId      INT,
  @AgencyId INT ,
  @ReviewerId INT ,
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
         --    FROM ReviewXUsers
         --    WHERE ReviewId = @ReviewId and UserId= @UserId
         --)
             BEGIN
                 INSERT INTO  [dbo].ReviewXUsers
                 (ReviewId ,
				  UserId, 
				  AgencyId,
				  SignName,
				  LastCompleteOn,
				  ComplianceOfficerId,
				  ReviewerId
				  
                 )
                 VALUES
                 (@ReviewId,
				  @UserId, 
				  @AgencyId,
				  @SignName,
				  @LastCompleteOn,
				  @ComplianceOfficerId,
				 @ReviewerId

                 );
				  SET @IdCreated = @@IDENTITY;
   --      END;
		 --ELSE 
		 --BEGIN 
		 -- UPDATE [dbo].ReviewXUsers
   --                SET
			--	   AgencyId=@AgencyId,
			--	   LastCompleteOn= @LastCompleteOn				 
   --              WHERE UserId = @UserId;
			--SET  @IdCreated  = -1
			
			
		 END;
             
     END;
GO