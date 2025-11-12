SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateOthersxUser]
@UserId INT,
@OtherId INT
AS
     BEGIN
        
		INSERT INTO [dbo].[OthersxUser]
           ([OtherId]
           ,[UserId])
     VALUES
           (@OtherId
           ,@UserId)


     END;


GO