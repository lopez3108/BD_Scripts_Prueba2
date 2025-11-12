SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllReasons]

AS
     BEGIN
	SELECT ReasonId, Code, UPPER(Description) Description FROM REASONS Where not (Code = 'C01')
	 END
GO