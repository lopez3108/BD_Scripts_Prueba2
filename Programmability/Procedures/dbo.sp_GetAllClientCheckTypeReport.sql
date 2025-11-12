SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllClientCheckTypeReport]
AS 
  SELECT * FROM dbo.ClientCheckTypeReport
GO