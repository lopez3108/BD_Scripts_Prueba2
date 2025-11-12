SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[sp_SaveDirectory](@DirectoryId INT = NULL,
                                          @Company VARCHAR(100),
                                          @Telephone VARCHAR(50),
                                          @Extension VARCHAR(20) = NULL,
                                          @Department VARCHAR(50),
                                          @Email VARCHAR(70) = NULL,
                                          @Fax VARCHAR(15) = NULL,
                                          @IdSaved INT OUTPUT
)
AS
BEGIN
    IF (@DirectoryId IS NULL)
        BEGIN
            INSERT INTO [dbo].Directory
            (Company,
             Telephone,
             Extension,
             Department,
             Email,
             Fax)
            VALUES (@Company,
                    @Telephone,
                    @Extension,
                    @Department,
                    @Email,
                    @Fax);
            SET @IdSaved = @@IDENTITY;
        END;
    ELSE
        BEGIN
            UPDATE [dbo].Directory
            SET Company    = @Company,
                Telephone  = @Telephone,
                Extension  = @Extension,
                Department = @Department,
                Email      = @Email,
                Fax        = @Fax
            WHERE DirectoryId = @DirectoryId;
            SET @IdSaved = @DirectoryId;
        END;
END;
GO