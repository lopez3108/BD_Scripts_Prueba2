SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateInventoryElsAlert]
(
@InventoryELSId INT,
@QuantityOrdered INT,
@AgencyId INT,
@CreationDate DATETIME,
@CreatedBy INT
)
AS
     BEGIN
        
	INSERT INTO [dbo].[InventoryELSAlerts]
           ([InventoryELSId]
           ,[QuantityOrdered]
           ,[AgencyId]
           ,[CreationDate]
           ,[CreatedBy]
           )
     VALUES
           (@InventoryELSId,
@QuantityOrdered,
@AgencyId,
@CreationDate,
@CreatedBy)


		   SELECT @@IDENTITY
		

     END;
GO