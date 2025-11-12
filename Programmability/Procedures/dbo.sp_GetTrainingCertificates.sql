SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetTrainingCertificates](@UserId INT = NULL
 )
AS
    BEGIN
        SELECT 
		CAST(tu.LastCompleteOn AS DATE) LastCompleteOnDate,
		tu.LastCompleteOn,
        FORMAT(tu.LastCompleteOn, 'MM-dd-yyyy h:mm:ss tt', 'en-US')  LastCompleteOnFormat,
		a.Code +' - '+ a.Name as AgencyName,
		t.TrainingName,
		a.Code,
		u.Name,
		u.[User] AS Email,
		u.UserId,
		t.TrainingId
  FROM dbo.Training t
        INNER JOIN  dbo.TrainingXUsers tu ON t.TrainingId = tu.TrainingId 
		INNER JOIN  Agencies a on tu.AgencyId = a.AgencyId
		INNER JOIN  Users u ON tu.UserId = u.UserId
		WHERE TU.UserId = @UserId
	    ORDER BY   tu.LastCompleteOn desc
    END;
GO