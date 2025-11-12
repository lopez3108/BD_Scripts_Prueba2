SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create PROCEDURE [dbo].[sp_GetComplianceOfficer]
AS
     BEGIN
         SELECT C.UserId
		 FROM Cashiers C
     INNER JOIN RolCompliance rc ON C.ComplianceRol = rc.RolComplianceId
     WHERE rc.Code = 'C02'	               
     END;



GO