SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetGetInterviewePerson]
@ReviewId			  INT 
                                     
AS
     BEGIN
        
         	 SELECT 
		 U.Name ,
     U.UserId

		 from  ReviewXUsers RX
		 INNER JOIN Users U ON U.UserId =  RX.UserId
     WHERE @ReviewId = RX.ReviewId
  
	

           
     END;


GO