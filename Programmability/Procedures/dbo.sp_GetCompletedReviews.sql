SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetCompletedReviews]
@UserId				  INT			= NULL,
@FromDate             DATE          = NULL, 
@ToDate               DATE          = NULL, 
@AgencyId             INT           = NULL,
@ReviewId			  INT 

                                     
AS
     BEGIN
        
               SELECT 
			   U.Name AS CompletedByName,
			   RX.LastCompleteOn AS CompletedOn,
			   R.ReviewId,
			   RX.ReviewXUserId,
			   RX.UserId, r.ReviewName,
         UR.Name  AS LastUpdatedByName
               FROM ReviewXUsers RX
                    INNER JOIN Reviews R ON R.ReviewId = RX.ReviewId
				          	INNER JOIN Users U ON U.UserId =  RX.UserId
                    INNER JOIN users UR ON UR.UserId = R.LastUpdatedBy
               WHERE RX.ReviewId = @ReviewId 
			   AND(RX.UserId = @UserId
                      OR @UserId IS NULL) 
					  AND (RX.AgencyId = @AgencyId
					  OR @AgencyId IS NULL) 
                      AND ((CAST(RX.LastCompleteOn AS DATE) >= CAST(@FromDate AS DATE)
					  OR @FromDate IS NULL)
					  AND (CAST(RX.LastCompleteOn AS DATE) <= CAST(@ToDate AS DATE))
					  OR @ToDate IS NULL)
					  ORDER BY RX.LastCompleteOn DESC

           
     END;


GO