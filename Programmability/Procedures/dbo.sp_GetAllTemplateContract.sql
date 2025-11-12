SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllTemplateContract]
AS 
  SELECT * FROM TemplatesContract tc
GO