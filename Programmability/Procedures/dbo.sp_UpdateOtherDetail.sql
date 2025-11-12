SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_UpdateOtherDetail]
(@OtherDetailId INT            = NULL, 
 @Cash               DECIMAL(18, 2)  = NULL
)
AS
    BEGIN
        UPDATE [dbo].OthersDetails
          SET 
              Cash = @Cash
        WHERE 	OtherDetailId = @OtherDetailId;
    END;
GO