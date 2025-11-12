SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Created by jt/24-06-2025 task 6614 Add missing notes
CREATE PROCEDURE [dbo].[sp_SaveNotesXMissing]
    @CreatedBy INT,
    @Note VARCHAR(400),
    @CreationDate DATETIME,
    @UserId INT = NULL,
    @CashierId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF(@CashierId IS NOT NULL)
    BEGIN
    SET @UserId  = (SELECT UserId FROM Cashiers where CashierId = @CashierId)
    END

    INSERT INTO [dbo].[NotesXMissing] (
        CreatedBy,
        Note,
        CreationDate,
        UserId
    )
    VALUES (
        @CreatedBy,
        @Note,
        @CreationDate,
        @UserId
    );
END;
GO