SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_UpdateMakerConfigurationUrl]
(@Url    VARCHAR(500)
)
AS
     BEGIN
       
	   UPDATE Configuration SET MakerConfigurationUrl = @Url

	   SELECT 1

     END;
GO