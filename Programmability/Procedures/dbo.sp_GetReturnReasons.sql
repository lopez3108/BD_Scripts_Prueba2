SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReturnReasons]
 
AS 

BEGIN

SELECT 
	[ReturnReasonId],
	[Description] FROM [ReturnReason]
	ORDER BY [Description]
	END
GO