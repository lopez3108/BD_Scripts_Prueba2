SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeletePropertiesBillWater]
 (
 @PropertiesBillWaterId INT,
		   @CurrentDate DATETIME
    )
AS 

BEGIN

declare @billWaterDate DATETIME
set @billWaterDate = (SELECT TOP 1 CreationDate FROM [dbo].[PropertiesBillWater] WHERE PropertiesBillWaterId = @PropertiesBillWaterId)

IF(CAST(@billWaterDate as date) <> CAST(@CurrentDate as date))
BEGIN

SELECT -1

END
ELSE
BEGIN

DELETE [dbo].[PropertiesBillWater]
WHERE PropertiesBillWaterId = @PropertiesBillWaterId

SELECT @PropertiesBillWaterId

END

	END
GO