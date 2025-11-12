SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetTrainingXUsers]
 @UserId  INT  
AS
    BEGIN 
	SELECT 
	TX.TrainingId,
	TX.LastCompleteOn,
	TX.AgencyId,
	TX.UserId as CompletedBy,
	U.[User] as Email,
	U.Name as NameUser

	FROM TrainingXUsers TX
	INNER JOIN Users U ON U.UserId = TX.UserId
	Inner JOIN Training T ON T.TrainingId = TX.TrainingId	
	where (TX.UserId= @UserId) 
    END;
GO