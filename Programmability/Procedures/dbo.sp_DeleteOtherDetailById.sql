SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteOtherDetailById](@OtherDetailId INT)
AS
    BEGIN
        DELETE FROM othersdetails
        WHERE OtherDetailId = @OtherDetailId;
    END;
GO