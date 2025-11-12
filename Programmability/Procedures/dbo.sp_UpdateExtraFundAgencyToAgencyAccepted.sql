SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_UpdateExtraFundAgencyToAgencyAccepted]
(
 @ExtraFundAgencyToAgencyId      INT, 
 @AcceptedBy         INT,
 @AcceptedDate         DATETIME,
 @AdminId INT = NULL
)
AS
    BEGIN

	DECLARE @agencyId INT

	 SELECT TOP 1 
	 @agencyId = e.ToAgencyId
	 FROM dbo.ExtraFundAgencyToAgency e WHERE e.ExtraFundAgencyToAgencyId = @ExtraFundAgencyToAgencyId
	
	 IF(EXISTS(SELECT TOP 1 * FROM dbo.Daily d
	 INNER JOIN dbo.Cashiers c ON c.CashierId = d.CashierId
	 INNER JOIN dbo.Users u ON u.UserId = c.UserId
	 WHERE (CAST(d.CreationDate as DATE) = CAST(@AcceptedDate as DATE) 
	 AND d.AgencyId = @agencyId AND u.UserId = @AcceptedBy
	 AND d.ClosedOn IS NOT NULL)) AND @AdminId IS NULL)
	 BEGIN

	 SELECT -2

	 END
	 ELSE
	 BEGIN

	IF((SELECT TOP 1 AcceptedBy FROM ExtraFundAgencyToAgency e WHERE e.ExtraFundAgencyToAgencyId = @ExtraFundAgencyToAgencyId) IS NOT NULL)
	BEGIN

	SELECT -1

	END
	ELSE
	BEGIN

UPDATE [dbo].[ExtraFundAgencyToAgency]
   SET 
      [AcceptedBy] = @AcceptedBy
      ,[AcceptedDate] = @AcceptedDate
 WHERE ExtraFundAgencyToAgencyId = @ExtraFundAgencyToAgencyId

 SELECT @ExtraFundAgencyToAgencyId

 END
		END
    END;
GO