SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GetReturnedChecksLawyerCourtFee] @ReturnedCheckId INT   
                                           

AS
     BEGIN
	
         SELECT dbo.ReturnedCheck.ReturnedCheckId,
          
 
                CASE
                    WHEN EXISTS
         (
             SELECT Usd
             FROM [dbo].[LawyerPayments]
             WHERE [dbo].[LawyerPayments].ReturnedCheckId = dbo.ReturnedCheck.ReturnedCheckId
         )
                    THEN
         (
             SELECT SUM(Usd)
             FROM [dbo].[LawyerPayments]
             WHERE [dbo].[LawyerPayments].ReturnedCheckId = dbo.ReturnedCheck.ReturnedCheckId
         )
                    ELSE 0.00
                END AS LawyerUsd,
               
                CASE
                    WHEN EXISTS
         (
             SELECT Usd
             FROM [dbo].[CourtPayment]
             WHERE [dbo].[CourtPayment].ReturnedCheckId = dbo.ReturnedCheck.ReturnedCheckId
         )
                    THEN
         (
             SELECT SUM(Usd)
             FROM [dbo].[CourtPayment]
             WHERE [dbo].[CourtPayment].ReturnedCheckId = dbo.ReturnedCheck.ReturnedCheckId
         )
                    ELSE 0.00
                END AS CourtUsd
                
         FROM 
              dbo.ReturnedCheck
       
		
		WHERE 
		
		 dbo.ReturnedCheck.ReturnedCheckId = @ReturnedCheckId
               
     END;










GO