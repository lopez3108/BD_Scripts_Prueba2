SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllProcessStatus]
AS
     BEGIN
         SELECT *
         FROM ProcessStatus
         ORDER BY [Order] ASC;
     END;
GO