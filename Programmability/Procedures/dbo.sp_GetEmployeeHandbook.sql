SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		Juan Felipe Oquendo
-- Description:	Crea una nota de una propiedad
-- =============================================

CREATE PROCEDURE [dbo].[sp_GetEmployeeHandbook]
AS
     BEGIN
         SELECT *,EH.EmployeeHandbook EmployeeHandbookSaved
		   
		 FROM EmployeeHandBook AS EH
		
                
     END;


GO