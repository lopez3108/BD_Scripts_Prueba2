SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllActiveAgenciesToProviders]
AS
     BEGIN
         SELECT Agencies.Code+' - '+Agencies.Name AS Agency,
                Agencies.AgencyId,
                 0 AS InitialBalance,
                 0  AS InitialBalanceSaved,
                 cast(0 AS bit) Disabled
             
         FROM Agencies
             
         WHERE Agencies.IsActive = 1
       
     END;


GO