SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetUrlXAgency] @AgencyId INT
AS
    BEGIN
        SELECT DISTINCT 
               u.Link,
			   a.AgencyId,
			   u.StateAbre
    FROM [dbo].agencies A
             INNER JOIN ZipCodes Z ON A.ZipCode = Z.ZipCode
             INNER JOIN urlsxstate U ON Z.StateAbre = U.StateAbre
        WHERE A.AgencyId = @AgencyId;
    END;
GO