SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--OBTIENE TODOS LOS DOCUMENTOS POR USERID #5006
--CREATEDBY: JOHAN
--19-04-2023
CREATE PROCEDURE [dbo].[sp_GetEmployeeWarningsDocuments]
	@UserId int
AS
BEGIN
	SELECT *,
  u.Name UserName,
  c.Name CreatedByName
	FROM dbo.EmployeeWarning  f
	INNER JOIN dbo.Users u on f.UserId = U.UserId
  INNER JOIN dbo.Users c on f.CreatedBy = c.UserId
	WHERE f.UserId = @UserId
	ORDER BY f.CreationDate desc	
END

GO