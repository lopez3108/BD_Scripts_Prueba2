SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		Juan Felipe Oquendo
-- Description:	Crea una nota de una propiedad
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreateEmployeeHandbook]
            @EmployeeHandbookId int = null,
            @EmployeeHandbook varchar(1000) = NULL
	      
		 AS
		  
BEGIN

IF(@EmployeeHandbookId IS NULL)
BEGIN

INSERT INTO [dbo].[EmployeeHandBook]
           ([EmployeeHandbook]
	)
     VALUES
            (@EmployeeHandbook
	)
                      
   		   SELECT @@IDENTITY
		     END
		   ELSE
		   BEGIN

		    UPDATE [dbo].EmployeeHandBook SET 
		   EmployeeHandbook =   @EmployeeHandbook	 
	
		 
		   WHERE EmployeeHandbookId	 = @EmployeeHandbookId

		   SELECT @EmployeeHandbookId
		   END
		  

END


GO