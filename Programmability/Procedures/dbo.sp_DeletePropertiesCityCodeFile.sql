SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-08-14 CB/6005: Added Properties city code files section

CREATE PROCEDURE [dbo].[sp_DeletePropertiesCityCodeFile]
@PropertiesCityCodeFilesId INT

AS
    BEGIN

DELETE [dbo].[PropertiesCityCodeFiles] WHERE PropertiesCityCodeFilesId = @PropertiesCityCodeFilesId


      

    END;
GO