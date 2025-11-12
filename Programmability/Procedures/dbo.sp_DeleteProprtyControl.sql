SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteProprtyControl] 
@PropertyControlId INT
AS
     BEGIN


IF(EXISTS(SELECT 1 FROM [dbo].[PropertyControlsXProperty] WHERE PropertyControlId = @PropertyControlId AND Completed = 1))
BEGIN

SELECT -1

END
ELSE IF ((SELECT TOP 1 Code From PropertyControls WHERE PropertyControlId = @PropertyControlId) = 'C1')
BEGIN

SELECT -2

END
ELSE
BEGIN

DELETE PropertyControlsXProperty where PropertyControlId = @PropertyControlId

DELETE PropertyControls WHERE PropertyControlId = @PropertyControlId

SELECT @PropertyControlId

END



     END;
GO