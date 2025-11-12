SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create procedure [dbo].[sp_DeleteRegisteredMacsById]  @RegisteredMacId Int =null
AS
Begin
Delete  From RegisteredMacs where  RegisteredMacId = @RegisteredMacId or @RegisteredMacId is null
End
GO