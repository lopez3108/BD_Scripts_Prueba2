SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetReviewCertificates](@UserId INT = NULL
 )
AS
    BEGIN
        SELECT 
		CAST(RU.LastCompleteOn AS DATE) LastCompleteOnDate,
		RU.LastCompleteOn,
		a.Code +' - '+ a.Name as AgencyName,
		R.ReviewName,
		a.Code,
		u.Name,
		u.[User] AS Email,
    u.UserId,
    r.ReviewId
  FROM dbo.Reviews R
        INNER JOIN  dbo.ReviewXUsers RU ON R.ReviewId = RU.ReviewId 
		INNER JOIN  Agencies a on RU.AgencyId = a.AgencyId
		INNER JOIN  Users u ON RU.UserId = u.UserId
		WHERE RU.UserId = @UserId
	    ORDER BY   RU.LastCompleteOn desc
    END;

GO