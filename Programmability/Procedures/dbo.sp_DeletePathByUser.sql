SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeletePathByUser]
(
	  @PahtByUserId int
)
AS
BEGIN
--First we need to delete childs for this parents

	DELETE FROM [dbo].PathsByUsers
	WHERE PahtByUserId = @PahtByUserId OR ParentId = @PahtByUserId
END
GO