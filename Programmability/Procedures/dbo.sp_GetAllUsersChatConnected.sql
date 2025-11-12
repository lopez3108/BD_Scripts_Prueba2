SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllUsersChatConnected]
(@Rol  varchar(50) = NULL,
 @AgencyConnectedId     INT = NULL,
 @UserId       INT = NULL,
 @ConnectionId       varchar(50) = NULL
)
AS
     BEGIN
         SELECT   IsOnline, AgencyConnectedId, ConnectionId,
		  C.UserId, usu.[User] UserName, Rol
         
         FROM UsersConnectedChat c
			   LEFT JOIN Users usu ON c.UserId = usu.UserId
         WHERE (c.Rol = @Rol OR @Rol IS NULL)
              AND (c.AgencyConnectedId = @AgencyConnectedId OR @AgencyConnectedId IS NULL)
              AND (c.UserId = @UserId OR @UserId IS NULL)
			  AND (c.ConnectionId = @ConnectionId OR @ConnectionId IS NULL);
     END;
GO