SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_UpdateLastLogin] @UserId INT,
@LastLoginDateAdmin DATETIME = null ,
@LastLoginDateManager DATETIME = null

AS
BEGIN

  UPDATE dbo.Users
  SET
  LastLoginDateAdmin = @LastLoginDateAdmin,
  LastLoginDateManager = @LastLoginDateManager
  WHERE UserId = @UserId
 
 
END;

GO