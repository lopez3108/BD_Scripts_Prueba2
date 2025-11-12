SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreateAgenciesxUser]
 (
      @UserId int,
	  @AgencyId int
    )
AS 

BEGIN


INSERT INTO [dbo].[AgenciesxUser]
           ([UserId]
           ,[AgencyId])
     VALUES
           (@UserId
           ,@AgencyId)

		   SELECT @@IDENTITY


	END


GO