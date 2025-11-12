SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteExtraFundAgencyToAgency]
@ExtraFundAgencyToAgencyId INT,
@AdminId INT = NULL
AS
     BEGIN

	 DECLARE @agencyId INT, @creationDate DATETIME, @createdBy INT

	 SELECT TOP 1 
	 @agencyId = e.FromAgencyId,
	 @creationDate = e.CreationDate,
	 @createdBy = e.CreatedBy
	 FROM dbo.ExtraFundAgencyToAgency e WHERE e.ExtraFundAgencyToAgencyId = @ExtraFundAgencyToAgencyId

	 IF(EXISTS(SELECT TOP 1 * FROM dbo.Daily d
	 INNER JOIN dbo.Cashiers c ON c.CashierId = d.CashierId
	 INNER JOIN dbo.Users u ON u.UserId = c.UserId
	 WHERE (CAST(d.CreationDate as DATE) = CAST(@creationDate as DATE) 
	 AND d.AgencyId = @agencyId AND u.UserId = @createdBy
	 AND d.ClosedOn IS NOT NULL) AND @AdminId IS NULL))
	 BEGIN

	 SELECT -2

	 END
	 ELSE
	 BEGIN

	 IF((SELECT TOP 1 ex.AcceptedBy FROM ExtrafundAgencyToAgency ex 
	 WHERE ExtraFundAgencyToAgencyId = @ExtraFundAgencyToAgencyId) IS NOT NULL)
	 BEGIN

	 SELECT -1

	 END
	 ELSE
	 BEGIN

	 DELETE [dbo].[ExtraFundAgencyToAgency]
	WHERE ExtraFundAgencyToAgencyId = @ExtraFundAgencyToAgencyId

	SELECT @ExtraFundAgencyToAgencyId

 END
 END

END;
GO