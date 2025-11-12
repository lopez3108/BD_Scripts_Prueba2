SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetTypeId]
AS
     BEGIN
         SELECT [TypeId],
                UPPER([Description]) Description
         FROM [dbo].[TypeID]
	    ORDER BY Description;
     END;
GO