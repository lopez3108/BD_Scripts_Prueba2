SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_ConnectUserChat]
(
@UserId       INT ,
@IsOnline     BIT , 
@AgencyConnectedId       INT =NULL ,
@ConnectionId          VARCHAR(50),
@Rol         VARCHAR(15)  = NULL
--@LastConnectionDate DATETIME         = NULL
 
)
AS
     BEGIN
	 IF(@IsOnline = 1)
	 BEGIN
         INSERT INTO  [dbo].UsersConnectedChat                   
                     ( UserId, IsOnline, AgencyConnectedId ,ConnectionId, Rol ) 
					 VALUES(
						 @UserId,
						 @IsOnline,
                         @AgencyConnectedId,
                         @ConnectionId,
						 @Rol
					     )
                 
		END
		ELSE
		BEGIN 
		DELETE FROM UsersConnectedChat WHERE ConnectionId = @ConnectionId
		END
	 END
GO