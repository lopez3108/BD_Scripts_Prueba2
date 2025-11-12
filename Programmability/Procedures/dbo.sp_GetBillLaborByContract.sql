SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetBillLaborByContract]
 (
      @ContractId INT
    )
AS 

BEGIN

SELECT pb.CreationDate, pb.Name, pb.DepositUsed, u.Name as CreatedBy FROM PropertiesBillLabor pb 
INNER JOIN Users u ON pb.CreatedBy = u.UserId
WHERE pb.ContractId = @ContractId AND pb.DepositUsed > 0


	END
GO