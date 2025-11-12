SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_DeleteRouting]
@RoutingId INT
AS
BEGIN
    
	DECLARE @numberOriginal VARCHAR(16)
SET @numberOriginal = (SELECT TOP 1 Number FROM Routings Where RoutingId = @RoutingId)


-- Checks if changing the number, if there are checks that contains the routing number
IF(EXISTS(SELECT * FROM Checks WHERE Routing = @numberOriginal))
BEGIN

SELECT -1

END
ELSE

-- ReturnedCheck if changing the number, if there are checks that contains the routing number
IF(EXISTS(SELECT * FROM ReturnedCheck WHERE Routing = @numberOriginal ))
BEGIN

SELECT -1

END
ELSE


BEGIN

DELETE Routings WHERE RoutingId = @RoutingId

SELECT @RoutingId



END






END
GO