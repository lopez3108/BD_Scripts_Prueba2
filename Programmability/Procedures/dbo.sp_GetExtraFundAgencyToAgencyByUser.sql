SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetExtraFundAgencyToAgencyByUser]
@CreatedBy INT = NULL,
@FromAgencyId INT = NULL,
@CreationDate DATETIME = NULL
AS
     BEGIN

	  DECLARE @userRight BIT

	 IF(EXISTS(SELECT 
r.UserId
from RightsxUser r
WHERE SUBSTRING(r.Rights, 26, 1) = '1' 
AND r.UserId = @CreatedBy))
BEGIN

SET @userRight = CAST(1 as BIT)

END
ELSE
BEGIN

SET @userRight = CAST(0 as BIT)


END

SELECT DISTINCT * FROM (
SELECT 
1 as [Order]
,e.[ExtraFundAgencyToAgencyId]
      ,e.[FromAgencyId]
	  ,af.Code + ' - ' + af.Name as FromAgencyCodeName
      ,e.[ToAgencyId]
	  ,at.Code + ' - ' + at.Name as ToAgencyCodeName
      ,e.[Usd]
      ,e.[CreatedBy]
	  ,UPPER(uc.Name) as CreatedByName
      ,e.[CreationDate]
      ,e.[AssignedTo]
	  ,UPPER(ua.Name) as AssignedToName
      ,e.[AcceptedBy]
	  ,UPPER(uac.Name) as AcceptedByName
      ,e.[AcceptedDate]
	  ,CASE WHEN e.[AcceptedBy] IS NOT NULL THEN
	  'ACCEPTED' ELSE
	  'PENDING' END AS [ExtraFundStatus]
  FROM [dbo].[ExtraFundAgencyToAgency] e
  INNER JOIN dbo.Agencies af ON af.AgencyId = e.FromAgencyId 
  INNER JOIN dbo.Agencies at ON at.AgencyId = e.ToAgencyId
  INNER JOIN dbo.Users uc ON uc.UserId = e.CreatedBy
  INNER JOIN dbo.Users ua ON ua.UserId = e.AssignedTo
  LEFT JOIN dbo.Users uac ON uac.UserId = e.AcceptedBy
  WHERE e.FromAgencyId = @FromAgencyId 
  AND e.CreatedBy = @CreatedBy
  AND CAST(e.CreationDate as DATE) = CAST(@CreationDate as DATE)
  UNION ALL
  SELECT 
2 as [Order]
,e.[ExtraFundAgencyToAgencyId]
      ,e.[FromAgencyId]
	  ,af.Code + ' - ' + af.Name as FromAgencyCodeName
      ,e.[ToAgencyId]
	  ,at.Code + ' - ' + at.Name as ToAgencyCodeName
      ,(e.[Usd] * -1) as Usd
      ,e.[CreatedBy]
	  ,UPPER(uc.Name) as CreatedByName
      ,e.[CreationDate]
      ,e.[AssignedTo]
	  ,UPPER(ua.Name) as AssignedToName
      ,e.[AcceptedBy]
	  ,UPPER(uac.Name) as AcceptedByName
      ,e.[AcceptedDate]
	  ,CASE WHEN e.[AcceptedBy] IS NOT NULL THEN
	  'ACCEPTED' ELSE
	  'PENDING' END AS [ExtraFundStatus]
  FROM [dbo].[ExtraFundAgencyToAgency] e
  INNER JOIN dbo.Agencies af ON af.AgencyId = e.FromAgencyId 
  INNER JOIN dbo.Agencies at ON at.AgencyId = e.ToAgencyId
  INNER JOIN dbo.Users uc ON uc.UserId = e.CreatedBy
  INNER JOIN dbo.Users ua ON ua.UserId = e.AssignedTo
  LEFT JOIN dbo.Users uac ON uac.UserId = e.AcceptedBy
  WHERE e.AcceptedBy = @CreatedBy 
  AND CAST(e.AcceptedDate as DATE) = CAST(@CreationDate as DATE)
  AND e.ToAgencyId = @FromAgencyId
  UNION ALL
  SELECT 
  3 as [Order]
  ,e.[ExtraFundAgencyToAgencyId]
      ,e.[FromAgencyId]
	  ,af.Code + ' - ' + af.Name as FromAgencyCodeName
      ,e.[ToAgencyId]
	  ,at.Code + ' - ' + at.Name as ToAgencyCodeName
      ,(e.[Usd] * -1) as Usd
      ,e.[CreatedBy]
	  ,UPPER(uc.Name) as CreatedByName
      ,e.[CreationDate]
      ,e.[AssignedTo]
	  ,UPPER(ua.Name) as AssignedToName
      ,e.[AcceptedBy]
	  ,UPPER(uac.Name) as AcceptedByName
      ,e.[AcceptedDate]
	  ,CASE WHEN e.[AcceptedBy] IS NOT NULL THEN
	  'ACCEPTED' ELSE
	  'PENDING' END AS [ExtraFundStatus]
  FROM [dbo].[ExtraFundAgencyToAgency] e
  INNER JOIN dbo.Agencies af ON af.AgencyId = e.FromAgencyId 
  INNER JOIN dbo.Agencies at ON at.AgencyId = e.ToAgencyId
  INNER JOIN dbo.Users uc ON uc.UserId = e.CreatedBy
  INNER JOIN dbo.Users ua ON ua.UserId = e.AssignedTo
  LEFT JOIN dbo.Users uac ON uac.UserId = e.AcceptedBy
  WHERE e.ToAgencyId = @FromAgencyId 
  AND e.AcceptedBy IS NULL

  UNION ALL
  SELECT 
4 as [Order]
,e.[ExtraFundAgencyToAgencyId]
      ,e.[FromAgencyId]
	  ,af.Code + ' - ' + af.Name as FromAgencyCodeName
      ,e.[ToAgencyId]
	  ,at.Code + ' - ' + at.Name as ToAgencyCodeName
      ,(e.[Usd] * -1) as Usd
      ,e.[CreatedBy]
	  ,UPPER(uc.Name) as CreatedByName
      ,e.[CreationDate]
      ,e.[AssignedTo]
	  ,UPPER(ua.Name) as AssignedToName
      ,e.[AcceptedBy]
	  ,UPPER(uac.Name) as AcceptedByName
      ,e.[AcceptedDate]
	  ,CASE WHEN e.[AcceptedBy] IS NOT NULL THEN
	  'ACCEPTED' ELSE
	  'PENDING' END AS [ExtraFundStatus]
  FROM [dbo].[ExtraFundAgencyToAgency] e
  INNER JOIN dbo.Agencies af ON af.AgencyId = e.FromAgencyId 
  INNER JOIN dbo.Agencies at ON at.AgencyId = e.ToAgencyId
  INNER JOIN dbo.Users uc ON uc.UserId = e.CreatedBy
  INNER JOIN dbo.Users ua ON ua.UserId = e.AssignedTo
  LEFT JOIN dbo.Users uac ON uac.UserId = e.AcceptedBy
  WHERE @CreatedBy IS NULL
  AND e.AcceptedBy IS NULL
  ) q ORDER BY q.[Order], q.CreationDate DESC 

END;
GO