SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetMakerConfigurationUrl]
AS
     BEGIN
       
	  SELECT MakerConfigurationUrl FROM Configuration

     END;
GO