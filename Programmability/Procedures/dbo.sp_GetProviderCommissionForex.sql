SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetProviderCommissionForex]
(@ProviderId INT = NULL,
 @AgencyId   INT,
 @Year       INT,
 @Month      INT
)
AS
     BEGIN
         


		 SELECT ISNULL(SUM(f.Usd),0) as Usd FROM dbo.Forex f 
		 WHERE f.AgencyId = @AgencyId
		 AND f.ProviderId = @ProviderId
               AND DATEPART(month, f.FromDate) = @Month
               AND DATEPART(year, f.FromDate) = @Year


														   
     END;
GO