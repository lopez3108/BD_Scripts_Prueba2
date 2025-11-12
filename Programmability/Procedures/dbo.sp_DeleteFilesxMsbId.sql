SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		cmontoya
-- Create date: 12Marzo2020
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[sp_DeleteFilesxMsbId]
	@MsbId int
AS
BEGIN
DELETE Msb
WHERE MsbId = @MsbId
END
GO