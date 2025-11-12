SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllAmindsWithoutRol] (@IsActive BIT = NULL)
AS
     BEGIN
         SELECT DISTINCT
                Users.Name,
                Users.UserId
         FROM Users
              INNER JOIN Cashiers  ON Cashiers.UserId = Users.UserId
              INNER JOIN RolCompliance rc ON rc.RolComplianceId = Cashiers.ComplianceRol
         WHERE IsAdmin = 1 and (Cashiers.IsActive = @IsActive
                  OR @IsActive IS NULL) AND rc.Code ='C01'
				  ORDER BY Name ASC

     END;
GO