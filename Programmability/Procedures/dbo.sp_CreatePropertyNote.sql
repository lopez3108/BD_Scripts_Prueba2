SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		David Jaramillo
-- Description:	Crea una nota de una propiedad
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreatePropertyNote]
@PropertiesId INT,
 @Note VARCHAR(300)
           ,@CreationDate DATETIME
           ,@CreatedBy INT
		 AS
		  
BEGIN

INSERT INTO [dbo].[PropertyNotes]
           ([PropertiesId]
           ,[Note]
           ,[CreationDate]
           ,[CreatedBy])
     VALUES
           (@PropertiesId
           ,@Note
           ,@CreationDate
           ,@CreatedBy)
                      

					  SELECT @@IDENTITY

END
GO