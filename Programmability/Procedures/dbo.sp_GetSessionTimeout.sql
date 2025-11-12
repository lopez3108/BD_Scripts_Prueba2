SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create PROCEDURE [dbo].[sp_GetSessionTimeout]
AS
     --SET NOCOUNT ON;
     BEGIN
         SELECT *
         FROM [dbo].ConfigurationSession
		 
         
		
     END;
GO