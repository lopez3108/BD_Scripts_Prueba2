SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllNewGroup] @GroupId  INT
                                           
                                             
AS
    BEGIN
      SELECT *
	  FROM Groups
        WHERE(GroupId = @GroupId)
		
             
    END;
GO