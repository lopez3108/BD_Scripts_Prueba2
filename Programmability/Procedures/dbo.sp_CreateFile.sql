SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreateFile]
 (
	  
	  @Name varchar (50),
	  @Description varchar (300),
	  @Location varchar(300),
	  @UploadedBy int,
	  @DateUploaded datetime

    )
AS 

BEGIN

INSERT INTO [dbo].[Files]
           ([Name]
           ,[Description]
           ,[Location]
           ,[UploadedBy]
           ,[DateUploaded])
     VALUES
           (@Name
           ,@Description
           ,@Location
           ,@UploadedBy
           ,@DateUploaded)

	END


GO