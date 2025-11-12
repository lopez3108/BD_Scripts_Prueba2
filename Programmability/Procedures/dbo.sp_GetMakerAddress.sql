SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetMakerAddress]
	@MakerId int
AS
BEGIN
    SELECT *
    FROM AddressXMaker
	WHERE MakerId = @MakerId
END
GO