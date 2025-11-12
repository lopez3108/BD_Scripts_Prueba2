SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Last update by JT/19-09-2024 task 6071 Refactory sp, to get better performance 
CREATE PROCEDURE [dbo].[sp_GetMakersByName] @Name VARCHAR(100) = NULL,
@Account VARCHAR(16) = NULL
AS
BEGIN
  SET NOCOUNT ON;

  SELECT DISTINCT
    m.MakerId
   ,m.Name
   ,m.FileNumber
   ,m.EntityTypeId
     ,FORMAT(m.IncorporationDate, 'MM-dd-yyyy', 'en-US') IncorporationDateFormat
   ,et.[Description] AS EntityTypeName
   ,m.Name AS NameSaved
   ,m.FileNumber AS FileNumberSaved
   ,m.EntityTypeId AS EntityTypeIdSaved
   ,m.IncorporationDate AS IncorporationDateSaved
   ,u.Name AS ValidatedByMaker
   ,m.ValidatedMakerBy
   ,m.ValidatedMakerOn
     ,FORMAT(m.ValidatedMakerOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US') ValidatedMakerOnFormat
   ,m.UpdatedOn AS ValidatedOn
   ,UPPER(A.Code + ' - ' + A.Name) AS AgencyName
   ,UPPER(usr.Name) AS CreatedByName
   ,m.NoRegistered AS CheckNoRegistered
   ,CASE
      WHEN m.NoRegistered = 1 THEN 'NO'
      ELSE 'YES'
    END AS [CheckNoRegisteredFormat]
   ,m.NoRegistered AS CheckNoRegisteredSaved
   ,us.Link
   ,m.AgencyId
  FROM dbo.Makers m
  LEFT JOIN dbo.EntityTypes et
    ON m.EntityTypeId = et.EntityTypeId
  LEFT JOIN Users u
    ON u.UserId = m.ValidatedMakerBy
  LEFT JOIN Agencies A
    ON A.AgencyId = m.AgencyId
  LEFT JOIN dbo.Users usr
    ON usr.UserId = m.CreatedBy
  LEFT JOIN dbo.UrlsXState us
    ON m.OtherStateId = us.UrlXStateId
  LEFT JOIN Checks
    ON Checks.Maker = m.MakerId --Last update by JT/19-09-2024 task 6071 Refactory sp, to get better performance 

  LEFT JOIN ReturnedCheck
    ON ReturnedCheck.MakerId = m.MakerId --Last update by JT/19-09-2024 task 6071 Refactory sp, to get better performance 

  WHERE (m.Name LIKE '%' + @Name + '%'
  OR @Name IS NULL)
  AND (@Account IS NOT NULL
  AND (Checks.Account IS NOT NULL
  AND Checks.Account = @Account
  OR ReturnedCheck.Account IS NOT NULL
  AND ReturnedCheck.Account = @Account)
  OR @Account IS NULL)--Last update by JT/19-09-2024 task 6071 Refactory sp, to get better performance 
  ORDER BY m.Name;
END

GO