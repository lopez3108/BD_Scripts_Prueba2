SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		Johan
-- Description:	Crea una nota de fraud alert
-- Creation date: 
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetCreateFraudNote]
@FraudId INT ,
           @Note VARCHAR(300)
           ,@CreationDate DATETIME
           ,@CreatedBy INT,
            @IdSaved              INT OUTPUT
         
		 AS
		  
BEGIN

INSERT INTO [dbo].FraudNotes
           (FraudId
           ,[Note]
           ,[CreationDate]
           ,CreatedBy
          )
     VALUES
           (@FraudId
           ,@Note
           ,@CreationDate
           ,@CreatedBy
           )
                      

					  SET @IdSaved = @@IDENTITY;

END




GO