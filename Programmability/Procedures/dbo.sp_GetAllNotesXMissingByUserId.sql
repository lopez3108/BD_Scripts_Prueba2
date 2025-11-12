SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Created by jt/24-06-2025 task 6614 Add missing notes
CREATE PROCEDURE [dbo].[sp_GetAllNotesXMissingByUserId]
    @CashierId INT  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @UserId INT;
    
    SET @UserId  = (SELECT UserId FROM Cashiers where CashierId = @CashierId)

    SELECT nm.* FROM NotesXMissing nm INNER JOIN Users u on u.UserId =  nm.CreatedBy WHERE nm.UserId = @UserId

END;
GO