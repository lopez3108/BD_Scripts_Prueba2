SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetCountExtraFundAgencyToAgencyByUser]
@CreatedBy INT = NULL,
@FromAgencyId INT = NULL,
@CreationDate DATETIME = NULL
AS
     BEGIN

	   DECLARE @result INT

SET @result = (ISNULL((SELECT COUNT(*)
from dbo.ExtraFundAgencyToAgency e 
WHERE e.FromAgencyId = @FromAgencyId 
  AND e.CreatedBy = @CreatedBy
  AND CAST(e.CreationDate as DATE) = CAST(@CreationDate as DATE)),0)) +
(ISNULL((SELECT COUNT(*)
from dbo.ExtraFundAgencyToAgency e 
WHERE e.AcceptedBy = @CreatedBy 
  AND CAST(e.AcceptedDate as DATE) = CAST(@CreationDate as DATE)
  AND e.ToAgencyId = @FromAgencyId),0))

  SELECT @result


END;
GO