SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		David Jaramillo
-- Description:	Crea un archivo de cheque retornado
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreateReturnFile]
@ReturnedCheckId INT,
 @Name VARCHAR(100)
           ,@CreationDate DATETIME
           ,@CreatedBy INT
		 AS
		  
BEGIN

INSERT INTO [dbo].[ReturnFiles]
           ([Name]
		   ,[ReturnedCheckId]
           ,[CreationDate]
           ,[CreatedBy])
     VALUES
(
           @Name
		   ,@ReturnedCheckId
           ,@CreationDate
           ,@CreatedBy)
                      

					  SELECT @@IDENTITY

END
GO