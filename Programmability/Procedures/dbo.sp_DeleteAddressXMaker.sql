SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_DeleteAddressXMaker](@AddressXMakerId INT)
AS
     BEGIN
         DELETE A
         FROM dbo.AddressXMaker A
         WHERE A.AddressXMakerId = @AddressXMakerId
     END;



GO