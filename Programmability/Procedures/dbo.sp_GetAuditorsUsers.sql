SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GetAuditorsUsers]                           
AS
     BEGIN  
		 SELECT 
		 U.Name AS AuditorName,
		 C.UserId,
		 C.CashierId
		 from  Cashiers C
		 INNER JOIN Users U ON U.UserId =  C.UserId
		 INNER JOIN RolCompliance R ON R.RolComplianceId = C.ComplianceRol
		 WHERE R.Code = 'C03' 
           
     END;
GO