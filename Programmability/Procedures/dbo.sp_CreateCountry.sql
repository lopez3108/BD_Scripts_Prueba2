SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateCountry]
 (
      @CountryId int = null,
	  @Name varchar(255)
    )
AS 

BEGIN

IF(@CountryId IS NULL)
BEGIN

INSERT INTO [dbo].[Countries]
           ([Name])
     VALUES
           (@Name)

		   SELECT @@IDENTITY


END
ELSE
BEGIN

UPDATE [dbo].[Countries]
   SET [Name] = @Name
 WHERE CountryId = @CountryId

 SELECT @CountryId


END

	END

GO