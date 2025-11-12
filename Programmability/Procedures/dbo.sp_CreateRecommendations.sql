SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[sp_CreateRecommendations] 
@RecommendationId INT = NULL,
@ReviewXUserId INT,
@Recommendation Varchar(300),
@IdCreated      INT OUTPUT

AS
    
     BEGIN
        IF(@RecommendationId IS NULL)
             BEGIN
                 INSERT INTO [dbo].Recommendations
                 (ReviewXUserId,
                  Recommendation				                  
                 )
                 VALUES
                 (@ReviewXUserId,
                  @Recommendation	
                 );
				  SET @IdCreated = @@IDENTITY;
				 
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].Recommendations
                   SET
				  ReviewXUserId = @ReviewXUserId,
                  Recommendation = @Recommendation
                 WHERE RecommendationId = @RecommendationId;
				  SET @IdCreated = @RecommendationId;
				   
         END;
     END;
GO