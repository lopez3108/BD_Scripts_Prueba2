SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetComplianceRol] @UserId INT = NULL,  @Rol BIT
                                     
AS
     BEGIN
         
               SELECT U.Name,
               U.UserId
               FROM Cashiers C
                    INNER JOIN RolCompliance r ON r.RolComplianceId = C.ComplianceRol
					INNER JOIN Users U ON U.UserId =  C.UserId
               WHERE ((@Rol = 1 AND  r.Code = 'C02')OR (@Rol = 0 AND  r.Code = 'C03'))
                     AND IsAdmin = 1
                     AND C.IsActive = 1
                     AND (C.UserId != @UserId
                          OR @UserId IS NULL)
     
     END;




GO