SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		Juan Felipe Oquendo López
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_SaveAgenciesXOrdersSupplies]
        @AgenciesXOrdersSuppliesId     INT = NULL,                                                  
		@OrderOfficeSupplieId          INT,       
		@AgencyId                      INT, 		 
        @IdCreated                     INT OUTPUT
AS
    BEGIN
        IF(@AgenciesXOrdersSuppliesId   IS NULL)
            BEGIN
                INSERT INTO [dbo].AgenciesXOrdersSupplies ([AgenciesXOrdersSuppliesId],[AgencyId])
                VALUES     (@OrderOfficeSupplieId,@AgencyId);
                SET @IdCreated = @@IDENTITY;
            END;
            ELSE
            BEGIN
                UPDATE [dbo].AgenciesXOrdersSupplies
                  SET 
                      [OrderOfficeSupplieId]  = @OrderOfficeSupplieId , 
                      [AgencyId]              = @AgencyId
					

                 WHERE  AgenciesXOrdersSuppliesId =  @AgenciesXOrdersSuppliesId ;
                SET @IdCreated = @AgenciesXOrdersSuppliesId;
            END;
    END;

GO