SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GetCompletedTrainings]
@UserId				  INT			= NULL,
@FromDate             DATE          = NULL, 
@ToDate               DATE          = NULL, 
@AgencyId             INT           = NULL,
@TrainingId				INT 
                                     
AS
     BEGIN
        
               SELECT 
			   U.Name AS CompletedByName,
			   TX.LastCompleteOn AS CompletedOn,
			   T.TrainingId,
			   TX.TrainingXUserId,
			   TX.UserId
               FROM TrainingXUsers TX
                    INNER JOIN Training T ON T.TrainingId = TX.TrainingId
					INNER JOIN Users U ON U.UserId =  TX.UserId
               WHERE TX.TrainingId = @TrainingId  
			   AND(TX.UserId = @UserId
                      OR @UserId IS NULL) 
					  AND (TX.AgencyId = @AgencyId
					  OR @AgencyId IS NULL) 
                      AND ((CAST(TX.LastCompleteOn AS DATE) >= CAST(@FromDate AS DATE)
					  OR @FromDate IS NULL)
					  AND (CAST(TX.LastCompleteOn AS DATE) <= CAST(@ToDate AS DATE))
					  OR @ToDate IS NULL)
					    ORDER BY TX.LastCompleteOn DESC
           
     END;
GO