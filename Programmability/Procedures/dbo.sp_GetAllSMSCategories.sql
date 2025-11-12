SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllSMSCategories]
(
@ListCodes char(400)        = NULL
)
AS
 

	  BEGIN
SELECT
	*
FROM SMSCategories
WHERE Code In (Select ParsedString From dbo.ParseStringList(@ListCodes))
OR @ListCodes IS NULL
ORDER BY Description;
END
GO