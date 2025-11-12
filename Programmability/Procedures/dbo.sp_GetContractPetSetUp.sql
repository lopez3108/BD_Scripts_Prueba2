SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetContractPetSetUp] 
                                            @ContractId   int
AS
    BEGIN
        SELECT c.*,
		p.Code,
		p.Name,
		cast(1 as bit) checkPet
        FROM PetsXContract c
		right join pets p on p.petId = c.petId
        WHERE ContractId = @ContractId
    END;

	select * from pets
	select * from PetsXContract
GO