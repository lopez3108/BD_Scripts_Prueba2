SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_DeleteConfigurationEmailById]
 @EmailsId int 
	
	
AS
BEGIN
	   DELETE Emails
         WHERE EmailsId = @EmailsId;
	    SELECT 1;
END
GO