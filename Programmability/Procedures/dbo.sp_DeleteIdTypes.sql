SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create PROCEDURE [dbo].[sp_DeleteIdTypes]
(@IdTypes INT
)
AS    
	 BEGIN

DELETE dbo.TypeID
WHERE TypeId = @IdTypes

END
GO