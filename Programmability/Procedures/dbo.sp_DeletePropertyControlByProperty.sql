SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeletePropertyControlByProperty] 
@PropertyControlsXPropertyId INT
AS
     BEGIN

DELETE PropertyControlsXProperty WHERE PropertyControlsXPropertyId = @PropertyControlsXPropertyId

SELECT @PropertyControlsXPropertyId

END
GO