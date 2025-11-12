SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveCountrie]
(@CountryId   INT            = NULL,
@Name           varchar(50),
@Currency varchar(4) = NULL
)
AS
     BEGIN
         IF(@CountryId IS NULL)
             BEGIN
                 INSERT INTO [dbo].Countries
                 (                
				  Name,                  
                 Currency
                 )
                 VALUES
                 (
                  @Name,
                 @Currency
                 );
                 --SET @IdCreated = @@IDENTITY;
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].Countries
                   SET                   
                  --Name = @Name,
                  Currency = @Currency
                 WHERE CountryId = @CountryId;
                 --SET @IdCreated = 0;
         END;
     END;
GO