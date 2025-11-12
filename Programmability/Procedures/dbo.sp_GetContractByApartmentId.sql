SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--CREATEDBY: JOHAN
--CREATEDON: 10-03-23
--USO: Verifica si un apartamente tiene un contracto.
CREATE PROCEDURE [dbo].[sp_GetContractByApartmentId] @ApartmentsId INT = NULL
AS
BEGIN
SELECT top 1 c.ContractId FROM Contract c
WHERE c.ApartmentId = @ApartmentsId
END

GO