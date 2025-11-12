SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		Johan
-- Description:	Crea un archivo de fraud alerts
-- Created on : 16-05-2023
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreateFraudFile]
      @FraudDocumentId INT = NULL
     ,@FraudId INT
     , @Name VARCHAR(100)  = null
     , @CreationDate DATETIME,
         @IdSaved              INT OUTPUT   
		 AS

  IF (@FraudDocumentId  is NULL)
		  
    BEGIN

INSERT INTO [dbo].FraudFiles
           ([Name]
		       ,FraudId
           ,[CreationDate]
           )
     VALUES
        (
           @Name
		      ,@FraudId
           ,@CreationDate
          )                      

					 SET @IdSaved = @@IDENTITY;
   END

   ELSE 

   BEGIN
             UPDATE FraudFiles
                   SET
           FraudId = @FraudId,
           Name = @Name,
           CreationDate = @CreationDate     
 
                 WHERE FraudDocumentId = @FraudDocumentId;
                 SET @IdSaved = @FraudDocumentId;


   END





GO