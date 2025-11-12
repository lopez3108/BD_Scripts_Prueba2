SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllCheckListVehicleServices]
AS
     BEGIN
         SELECT *,
         cast(0 AS BIT) selected
             
         FROM CheckListVehicleServices
            
     END;

GO