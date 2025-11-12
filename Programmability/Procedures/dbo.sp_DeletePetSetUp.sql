SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeletePetSetUp]
	@PetIdXContract int
AS
BEGIN
	

	DELETE dbo.PetsXContract
	WHERE PetIdXContract = @PetIdXContract

	
END
GO