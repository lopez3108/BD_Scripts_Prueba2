SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*
	EXEC [sp_GetRoutings]
	@Number = '021207112',
	@BankName = 'NEW YORK COMMUNITY BANK',
	@State = 'NY'
*/

CREATE PROCEDURE [dbo].[sp_GetRoutings] @Number   VARCHAR(16) = NULL,
                                       @BankName VARCHAR(60) = NULL
                                       --@State    VARCHAR(10) = NULL
AS
     BEGIN
SELECT 
dbo.Routings.RoutingId, 
dbo.Routings.Number, 
dbo.Routings.BankName, 
dbo.Routings.BankPhone,
(dbo.AddressXRouting.Address + ' ' + dbo.AddressXRouting.City + ', ' + dbo.AddressXRouting.State + ' ' + dbo.AddressXRouting.ZipCode) as FullAddress,
dbo.AddressXRouting.Address, 
dbo.AddressXRouting.ZipCode, 
dbo.AddressXRouting.State, 
dbo.AddressXRouting.City,
dbo.AddressXRouting.County
FROM   dbo.Routings LEFT OUTER JOIN
                  dbo.AddressXRouting ON dbo.Routings.RoutingId = dbo.AddressXRouting.RoutingId
         WHERE(@Number IS NULL
               OR Number LIKE '%'+@Number+'%')
              AND (@BankName IS NULL
                   OR BankName LIKE '%'+@BankName+'%')
    
         ORDER BY Number;
     END;
GO