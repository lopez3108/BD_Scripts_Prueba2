SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateEmail]
(@EmailId INT          = NULL, 
 @Address VARCHAR(80), 
 @Name    VARCHAR(100),
 @Active  BIT = NULL
)
AS
    BEGIN
        IF(@EmailId IS NULL)
            BEGIN
                INSERT INTO [dbo].[Emails]
                ([Address], 
                 [Name],
				 [Active]
                )
                VALUES
                (@Address, 
                 @Name,
				 @Active
                );
                SELECT @@IDENTITY;
        END;
            ELSE
            BEGIN
                UPDATE Emails
                  SET 
                      Address = @Address, 
                      Name = @Name,
					  Active = @Active
                WHERE EmailsId = @EmailId;
                SELECT @EmailId;
        END;
    END;
GO