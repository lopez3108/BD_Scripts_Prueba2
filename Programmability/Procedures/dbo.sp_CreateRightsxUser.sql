SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CreateRightsxUser]
 (
      @UserId int,
	  @Rights varchar(400)
    )
AS 

BEGIN

INSERT INTO [dbo].[RightsxUser]
           ([UserId]
           ,[Rights])
     VALUES
           (@UserId
           ,@Rights)

		   SELECT @UserId

	END


GO