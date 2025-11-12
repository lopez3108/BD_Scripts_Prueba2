SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteGroupAndMembers](@GroupId INT)
AS
    BEGIN
        DELETE UsersXGroup
        WHERE GroupId = @GroupId;
        DELETE GROUPS
        WHERE GroupId = @GroupId;
    END;
GO