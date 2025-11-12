SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReportChecksInfo]
(@IDs VARCHAR(max),
@IDsReturn VARCHAR(max)
)
AS
     BEGIN

SELECT 
c.CheckId,
rt.ReturnedCheckId,
c.ClientId, 
CASE
                    WHEN c.CheckId IS NOT NULL
                    THEN c.CheckFront
                    ELSE rf.[Name]
                END AS CheckFront, 
c.CheckBack, 
 CASE
                    WHEN c.CheckId IS NOT NULL
                    THEN c.Number
                    ELSE RT.CheckNumber
                END AS Number, 
CASE
                    WHEN c.CheckId IS NOT NULL
                    THEN c.Account
                    ELSE rt.Account
                END AS Account, 
CASE
                    WHEN c.CheckId IS NOT NULL
                    THEN c.Routing
                    ELSE rt.Routing
                END AS Routing, 
 CASE
                    WHEN c.CheckId IS NOT NULL
                    THEN c.DateCheck
                    ELSE rt.CheckDate
                END AS DateCheck, 
 CASE
                    WHEN c.CheckId IS NOT NULL
                    THEN uc.Name
                    ELSE ucr.Name
                END AS CLientName,
CASE
                    WHEN c.CheckId IS NOT NULL
                    THEN m.Name
                    ELSE mr.Name
                END AS MakerName,
CASE
                    WHEN c.CheckId IS NOT NULL
                    THEN c.Amount
                    ELSE rt.USD
                END AS USD,
(select TOP 1 Name from [dbo].[CompanyInformation]) as CompanyName
FROM     dbo.Checks c INNER JOIN
                  dbo.Clientes ON c.ClientId = dbo.Clientes.ClienteId INNER JOIN
                  dbo.Users uc ON dbo.Clientes.UsuarioId = uc.UserId INNER JOIN
                  dbo.Makers m ON c.Maker = m.MakerId
				  FULL OUTER JOIN dbo.ReturnedCheck rt ON rt.CheckNumber = c.Number
				  LEFT JOIN dbo.Clientes cl ON rt.ClientId = cl.ClienteId
              LEFT JOIN dbo.Users AS ucr ON cl.UsuarioId = ucr.UserId
			  LEFT JOIN dbo.Makers mr ON mr.MakerId = rt.MakerId
			  LEFT JOIN dbo.ReturnFiles rf ON rf.ReturnedCheckId = rt.ReturnedCheckId
  where @IDs like '%;'+cast(c.checkId as varchar(20))+';%' OR
  @IDsReturn like '%;'+cast(rt.ReturnedCheckId as varchar(20))+';%'
  ORDER BY c.Amount DESC


         
     END;
GO