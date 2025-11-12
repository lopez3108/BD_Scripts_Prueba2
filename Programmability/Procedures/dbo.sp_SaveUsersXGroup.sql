SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Last update by JT/12-09-2024  El sistema no está permitiendo eliminar usuarios de un grupo

CREATE PROCEDURE [dbo].[sp_SaveUsersXGroup] @UserXGroupId INT = NULL,
@GroupId INT,
@UserId INT,
@CreationDate DATETIME = NULL,
@CreatedBy INT = NULL

AS

BEGIN
  IF (@UserXGroupId IS NULL)
  BEGIN
    INSERT INTO [dbo].UsersXGroup (GroupId,
    UserId,
    CreationDate,
    CreatedBy)
      VALUES (@GroupId, @UserId, @CreationDate, @CreatedBy);

  END;
--  ELSE --At this moment is not require update the userxgroups
--  BEGIN
--    UPDATE [dbo].UsersXGroup
--    SET GroupId = @GroupId
----       ,UserId = @UserId
----       ,CreationDate = @CreationDate
----       ,CreatedBy = @CreatedBy
--
--
--    WHERE UserXGroupId = @UserXGroupId;
--
--  END;
END;



GO