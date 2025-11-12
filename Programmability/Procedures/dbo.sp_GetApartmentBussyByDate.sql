SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetApartmentBussyByDate]
(@ApartmentId     INT,
@StartingDate DATETIME,
@EndDate DATETIME
)
AS
     BEGIN

	 DECLARE @activeStatus INT
	 SET @activeStatus = (SELECT top 1 ContractStatusId FROM ContractStatus WHERE Code = 'C01')

	 IF(EXISTS(SELECT *
FROM dbo.[Contract] c 
WHERE c.ApartmentId = @ApartmentId AND
c.Status = @activeStatus AND
(c.StartDate <= @EndDate
AND c.EndDate >= @StartingDate)))
BEGIN

SELECT CAST(1 as BIT) as IsBussy

END
ELSE
BEGIN

SELECT CAST(0 as BIT) as IsBussy

END
         
	




     END;

GO