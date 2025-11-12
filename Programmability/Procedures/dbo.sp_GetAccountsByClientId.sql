SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		John Terry García 
-- Description:	Selecciona cheques de returnedcheck y checks por clientId
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetAccountsByClientId] @ClientId INT         = NULL,
                                                 @Account  VARCHAR(50) = NULL
AS
     BEGIN
         SELECT DISTINCT
	     --c.CheckId,
                c.ClientId,
                --c.Number,
                c.Account,
                c.Routing,
                --r.BankAddress,
                r.BankName,
                --r.BankCity,
                --r.BankState,
                --r.BankZipCode,
                r.RoutingId,
                a.Address ClientAddress,
                a.City ClientCity,
                a.State ClientState,
                a.ZipCode ClientZipCode,
                am.Address MakerAddress,
                am.City MakerCity,
                am.State MakerState,
                am.ZipCode MakerZipCode,
                   '( Check Number: '+ c.Number  +')' AccountByCheckNumber
 
                --c.DateCheck
         FROM dbo.Checks c
              INNER JOIN Routings r ON c.Routing = r.Number
              INNER JOIN dbo.Makers ON C.Maker = dbo.Makers.MakerId
              LEFT JOIN AddressXClient A ON A.ClientId = c.ClientId
              LEFT JOIN AddressXMaker AM ON AM.MakerId = dbo.Makers.MakerId
         WHERE (C.ClientId = @ClientId OR @ClientId IS NULL)
           
               AND (c.Account LIKE '%'+@Account+'%'
                    OR @Account IS NULL)
         UNION ALL
         SELECT DISTINCT
	    --dbo.ReturnedCheck.ReturnedCheckId,
         C.ClientId,
         --dbo.ReturnedCheck.CheckNumber Number,
         C.Account,
         C.Routing,
         --r.BankAddress,
         r.BankName,
         --r.BankCity,
         --r.BankState,
         --r.BankZipCode,
         r.RoutingId,
         a.Address ClientAddress,
         a.City ClientCity,
         a.State ClientState,
         a.ZipCode ClientZipCode,
         am.Address MakerAddress,
         am.City MakerCity,
         am.State MakerState,
         am.ZipCode MakerZipCode,
                --dbo.ReturnedCheck.CheckDate
                '( Check Number: '+ c.CheckNumber  +')' AccountByCheckNumber
         FROM dbo.ReturnedCheck C
              INNER JOIN Routings r ON c.Routing = r.Number
              INNER JOIN dbo.Makers ON C.MakerId = dbo.Makers.MakerId
              LEFT JOIN AddressXClient A ON A.ClientId = c.ClientId
              LEFT  JOIN AddressXMaker AM ON AM.AddressXMakerId = C.AddressXMakerId
         WHERE (C.ClientId = @ClientId OR @ClientId IS NULL)
               AND (c.Account LIKE '%'+@Account+'%'
                    OR @Account IS NULL)
         ORDER BY Account ASC;
     END;


GO