SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveZipCode]
(@ZipCode VARCHAR(6)   = NULL,
 @City    VARCHAR(255) = NULL,
 @State   VARCHAR(255) = NULL,
 @County  VARCHAR(255) = NULL
)
AS
     BEGIN
         IF(NOT EXISTS
           (
               SELECT Zipcode
               FROM ZipCodes
               WHERE Zipcode = @Zipcode
           ))
             BEGIN
                 INSERT INTO [dbo].ZipCodes
                 (ZipCode,
                  City,
                  State,
                  County
                 )
                 VALUES
                 (@ZipCode,
                  @City,
                  @State,
                  @County
                 );
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].ZipCodes
                   SET                       
                       City = @City,
                       State = @State,
                       County = @County
                 WHERE Zipcode = @Zipcode
         END;
     END;
GO