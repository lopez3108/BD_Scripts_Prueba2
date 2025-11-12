SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetReturnsELSStatus]

AS 

BEGIN


SELECT
ReturnsELSStatusId,
Code,
Description
FROM ReturnELSStatus


	END
GO