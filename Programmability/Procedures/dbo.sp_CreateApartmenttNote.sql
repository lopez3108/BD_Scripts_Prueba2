SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		David Jaramillo
-- Description:	Crea una nota de un contrato
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreateApartmenttNote]
@ApartmentId INT,
 @Note VARCHAR(300)
           ,@CreationDate DATETIME
           ,@CreatedBy INT
		 AS
		  
BEGIN

INSERT INTO [dbo].[ApartmentNotes]
           ([ApartmentId]
           ,[Note]
           ,[CreationDate]
           ,[CreatedBy])
     VALUES
           (@ApartmentId
           ,@Note
           ,@CreationDate
           ,@CreatedBy)
                      

					  SELECT @@IDENTITY

END
GO