SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_UpdateReturnedCheckPaid]
 (

 @ReturnedCheckId int,
@ClientBlocked BIT,
@MakerBlocked BIT,
@AccountBlocked BIT,
@CreationDate DATETIME,
@CreatedBy INT

    )
AS 

BEGIN

UPDATE ReturnedCheck SET
ClientBlocked = @ClientBlocked,
MakerBlocked = @MakerBlocked,
AccountBlocked = @AccountBlocked,
LastModifiedDate = @CreationDate,
LastModifiedBy = @CreatedBy
WHERE ReturnedCheckId = @ReturnedCheckId

SELECT @ReturnedCheckId


	END
GO