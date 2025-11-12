SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_PropertiesBillInsuranceStatus](@PropertiesBillInsuranceId   INT, @Date DATETIME)
RETURNS INT
--WITH RETURNS NULL ON NULL INPUT
AS
     BEGIN
 
 declare @propertiesId INT
set @propertiesId = (SELECT TOP 1 PropertiesId FROM [PropertiesBillInsurance] WHERE
[PropertiesBillInsuranceId] = @PropertiesBillInsuranceId)

declare @status INT

declare @from datetime
set @from = (SELECT TOP 1 FromDate FROM [PropertiesBillInsurance] WHERE
[PropertiesBillInsuranceId] = @PropertiesBillInsuranceId)

declare @to datetime
set @to = (SELECT TOP 1 ToDate FROM [PropertiesBillInsurance] WHERE
[PropertiesBillInsuranceId] = @PropertiesBillInsuranceId)

IF(CAST(@from as date) <= cast(@Date as DATE) AND
CAST(@to as date) >= cast(@Date as DATE))
BEGIN

set @status = 1


 END
 ELSE IF(cast(@Date as DATE) > CAST(@to as date))
BEGIN

IF(EXISTS(SELECT 1 FROM [PropertiesBillInsurance] WHERE CAST(FromDate as date) >= CAST(@to as DATE) AND
PropertiesId = @propertiesId))
BEGIN

set @status = 1

END
ELSE
BEGIN
set @status = 2

END

END


			
			RETURN @status

     END;
GO