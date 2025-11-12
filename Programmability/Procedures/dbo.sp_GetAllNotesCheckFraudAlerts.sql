SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllNotesCheckFraudAlerts] @FraudId INT = NULL
AS
     BEGIN
         SELECT FraudNotesId,
                FraudId,
                Note,
                CreationDate, 
                U.Name AS CreatedByName 
                        
         FROM [dbo].[FraudNotes]          
      INNER JOIN  users U ON u.UserId = CreatedBy
         WHERE FraudId = @FraudId
         ORDER BY CreationDate;
     END;



GO