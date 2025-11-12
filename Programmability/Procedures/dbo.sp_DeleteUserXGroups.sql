SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[sp_DeleteUserXGroups](@UserXGroupId INT)
AS
     BEGIN
	  
         DELETE UsersXGroup
         WHERE UserXGroupId = @UserXGroupId;
         SELECT 1;
     END;
GO