SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetChecksElsDailyGroup]
(@Creationdate   DATE,
 @AgencyId       INT,
 @ProviderTypeId INT,
 @UserId         INT,
 @QueryGroup BIT
)
AS
SELECT CheckClientIdGuidGroup , COUNT(*) 
FROM [dbo].[ChecksEls] C
			LEFT JOIN Checks ch ON c.CheckId  = ch.CheckId
              LEFT JOIN PromotionalCodesStatus P ON c.CheckElsId = p.CheckId
              LEFT JOIN PromotionalCodes pc ON pc.PromotionalCodeId = p.PromotionalCodeId
			   LEFT JOIN Users usu ON c.LastUpdatedBy = usu.UserId
			   LEFT JOIN routings r ON C.Routing = r.Number
			   LEFT JOIN dbo.Makers m ON C.MakerId = m.MakerId
			   LEFT JOIN Clientes CL ON CL.ClienteId = C.ClientId  LEFT JOIN Users UCL ON UCL.UserId = CL.UsuarioId
         WHERE(CAST(C.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
               OR @CreationDate IS NULL)
              AND C.AgencyId = @AgencyId
              AND C.ProviderTypeId = @ProviderTypeId
              AND C.CreatedBy = @UserId
			  AND CheckClientIdGuidGroup IS NOT NULL
			  GROUP BY CheckClientIdGuidGroup
GO