SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetClientCheckTypes]
 @ClientId int
AS 

BEGIN

select Checks.CheckId, Checks.CheckTypeId, Checks.CheckFront, Checks.CheckBack, CheckTypes.Description from Checks
inner join (
select max(CheckId) as maxID, CheckTypeId from Checks WHERE ClientId = @ClientId group by CheckTypeId) ChecksJoin
on ChecksJoin.maxID = Checks.CheckId INNER JOIN
                         CheckTypes ON Checks.CheckTypeId = CheckTypes.CheckTypeId
	
	
	END

GO