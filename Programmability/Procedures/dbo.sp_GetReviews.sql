SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Last updated by JT/03-06-2025 Task 6649 Permitir administrar reviews externos

CREATE PROCEDURE [dbo].[sp_GetReviews] @Name VARCHAR(150) = NULL,
@ReviewId INT = NULL
AS
BEGIN
  SELECT
    R.ReviewId
   ,R.CreationDate
   ,FORMAT(R.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDateFormat
   ,R.ReviewName
   ,R.Status
   ,R.Status AS STATUS
   ,R.CycleDate
   ,R.DocumentName
   ,R.CreatedBy
   ,R.LastUpdatedOn
   ,FORMAT(R.ExpirationDateExternal, 'MM-dd-yyyy', 'en-US') ExpirationDateExternalOnFormat
   ,R.ExpirationDateExternal
   ,FORMAT(R.LastUpdatedOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US') LastUpdatedOnFormat
   ,U.Name AS LastUpdatedByName
   , --Reviewer name
    U.UserId AS LastUpdatedById
   ,D.Description
   ,D.DaysToCompleteStatusId
   ,CAST(R.CycleDate AS DATE) AS CycleDateFormat
   ,CASE
      WHEN D.Code = 'C01' THEN DATEADD(DAY, 10, R.CycleDate)
      WHEN D.Code = 'C02' THEN DATEADD(DAY, 20, R.CycleDate)
      ELSE DATEADD(DAY, 30, R.CycleDate)
    END AS DateChance
   ,CASE
      WHEN R.STATUS = '2' THEN 'ACTIVE'
      WHEN R.STATUS = '3' THEN 'INACTIVE'
    END AS StatusReview
   ,R.DocumentName AS DocumentNameSaved
   ,Uc.Name AS CreatedByName
     ,CASE
      WHEN R.IsExternalReview = 1 THEN '-'
      ELSE CAST((SELECT
        COUNT(Question)
      FROM ReviewQuestions
      WHERE ReviewId = R.ReviewId)AS VARCHAR(10))
    END 
    AS CountQuestiosns
   ,(SELECT
        UR.Name
      FROM Cashiers c
      INNER JOIN RolCompliance r
        ON r.RolComplianceId = c.ComplianceRol
      INNER JOIN Users UR
        ON UR.UserId = c.UserId
      WHERE r.Code = 'C02')
    AS ComplianceOfficer
   ,(SELECT
        Us.UserId
      FROM Cashiers C
      INNER JOIN RolCompliance RC
        ON RC.RolComplianceId = C.ComplianceRol
      INNER JOIN Users Us
        ON Us.UserId = C.UserId
      WHERE RC.Code = 'C02')
    ComplianceOfficerId
   ,R.IsExternalReview
   ,CASE
      WHEN R.IsExternalReview = 1 THEN 'YES'
      ELSE 'NO'
    END AS IsExternalReviewDesc
  FROM Reviews R
  LEFT JOIN Users U
    ON U.UserId = R.LastUpdatedBy
  LEFT JOIN Users Uc
    ON Uc.UserId = R.CreatedBy
  LEFT JOIN ReviewDaysStatus D
    ON D.DaysToCompleteStatusId = R.DaysToCompleteStatusId
  WHERE (R.ReviewName LIKE '%' + @Name + '%'
  OR @Name IS NULL)
  AND (R.ReviewId = @ReviewId
  OR @ReviewId IS NULL);
END;

GO