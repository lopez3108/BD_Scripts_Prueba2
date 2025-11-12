SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeletePropertiesBillOther]
 (
 @PropertiesBillOtherId INT,
		   @CurrentDate DATETIME
    )
AS 

BEGIN

declare @billOtherDate DATETIME
set @billOtherDate = (SELECT TOP 1 CreationDate FROM [dbo].[PropertiesBillOthers] WHERE PropertiesBillOtherId = @PropertiesBillOtherId)

IF(CAST(@billOtherDate as date) <> CAST(@CurrentDate as date))
BEGIN

SELECT -1

END
ELSE
BEGIN

DELETE [dbo].[PropertiesBillOthers]
WHERE PropertiesBillOtherId = @PropertiesBillOtherId

SELECT @PropertiesBillOtherId

END

	END
GO