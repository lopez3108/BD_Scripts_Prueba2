SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllPayrollChecksByDate]
(@From DATE,
 @To     DATE,
 @AgencyId INT,
 @CreatedBy INT
)
AS
BEGIN 

SELECT        
dbo.ChecksEls.CreationDate AS Date, 
dbo.ChecksEls.Amount as USD, 
dbo.ProviderTypes.Description as Name, 
dbo.ChecksEls.AgencyId
FROM            dbo.ChecksEls INNER JOIN
                         dbo.ProviderTypes ON dbo.ChecksEls.ProviderTypeId = dbo.ProviderTypes.ProviderTypeId
						 WHERE 
						 CAST(dbo.ChecksEls.CreationDate as DATE) >= CAST(@From as DATE) AND
						 CAST(dbo.ChecksEls.CreationDate as DATE) <= CAST(@To as DATE) AND
						 CreatedBy = @CreatedBy AND
						 AgencyId = @AgencyId






     END;
GO