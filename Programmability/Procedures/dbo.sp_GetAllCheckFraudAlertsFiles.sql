SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Created by Juan Felipe Oquendo lopez..
--17-Mayo-2023  Task 5067 Icono Check Fraud Alerts ..

CREATE PROCEDURE [dbo].[sp_GetAllCheckFraudAlertsFiles]
( 
 @FraudId INT 
)
AS
    BEGIN           
    
          SELECT fa.FraudDocumentId,
                 fa.FraudId, 
                 fa.Name,
                 fa.Name AS NameSaved        
                          

          FROM FraudFiles fa           
                       
          WHERE (  fa.FraudId  = @FraudId )
           
               
       
       
    END;



GO