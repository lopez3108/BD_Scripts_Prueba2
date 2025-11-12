SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetRoutingAddress] 
@RoutingId      INT      
AS
BEGIN


SELECT
AddressXRoutingId,
RoutingId,
[Address],
ZipCode,
[State],
City,
County
FROM AddressXRouting
WHERE RoutingId = @RoutingId

    
END
GO