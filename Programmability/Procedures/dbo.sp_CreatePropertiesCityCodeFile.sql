SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2024-08-14 CB/6005: Addes Properties city code files section

CREATE PROCEDURE [dbo].[sp_CreatePropertiesCityCodeFile]
(@FileName VARCHAR(200),
@LastUpdatedBy INT,
@LastUpdatedOn DATETIME

)
AS
    BEGIN

INSERT INTO [dbo].[PropertiesCityCodeFiles]
           ([Filename]
           ,[LastUpdatedBy]
           ,[LastUpdatedOn])
     VALUES
           (@FileName
           ,@LastUpdatedBy
           ,@LastUpdatedOn)

		   SELECT @@IDENTITY


      

    END;
GO