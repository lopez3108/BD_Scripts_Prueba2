SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetConciliationOtherTypes] 
AS
     BEGIN

SELECT * FROM [ConciliationOtherTypes]

END
GO