SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-08-23 CB/6015: Deletes a insurance company

CREATE PROCEDURE [dbo].[sp_DeleteInsuranceCompanies]
@InsuranceCompaniesId INT
AS 

BEGIN

DECLARE @result INT

 IF(EXISTS
                   (
                       SELECT i.InsurancePolicyId
                       FROM dbo.InsurancePolicy i
                       WHERE i.InsuranceCompaniesId = @InsuranceCompaniesId
                   ))
				   BEGIN


				   set @result = -1

				   END
				   ELSE
				   BEGIN

DELETE [dbo].[InsuranceCompanies] WHERE InsuranceCompaniesId = @InsuranceCompaniesId

set @result = @InsuranceCompaniesId

END

SELECT @result

	END
GO