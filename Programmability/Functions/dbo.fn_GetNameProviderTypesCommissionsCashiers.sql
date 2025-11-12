SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- Return de name for de ProviderTypesCommissionsCashiers by code
CREATE FUNCTION [dbo].[fn_GetNameProviderTypesCommissionsCashiers] (@Code CHAR(5) = NULL)
RETURNS VARCHAR(100)

AS
BEGIN
DECLARE @return VARCHAR(100)


  IF @Code = 'C01'
  BEGIN
    RETURN 'City stickers'
  END
  IF @Code = 'C02'
  BEGIN
    RETURN 'Registration renewal'
  END
  IF @Code = 'C03'
  BEGIN
    RETURN 'Titles and plates'
  END
  IF @Code = 'C04'
  BEGIN
    RETURN 'T.R.P (7-90 days)'
  END
    IF @Code = 'C05'
  BEGIN
    RETURN 'Telephones'
  END
    IF @Code = 'C06'
  BEGIN
    RETURN 'Personal loans'
  END
    IF @Code = 'C07' OR @Code = 'C08'
  BEGIN
    RETURN 'Traffic tickets'
  END
RETURN @return

END;




GO