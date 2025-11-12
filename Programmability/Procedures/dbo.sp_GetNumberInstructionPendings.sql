SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetNumberInstructionPendings](@AgencyId AS INT)
AS
     BEGIN
      
         SELECT 
		 COUNT(*) Pendings
		 FROM dbo.InstructionChange i
		 INNER JOIN InstructionChangeStatus S ON S.StatusId =I.StatusId
         WHERE (S.Code = 'C02') AND (i.AgencyId = @AgencyId)
           
		     
     END;

	 
GO