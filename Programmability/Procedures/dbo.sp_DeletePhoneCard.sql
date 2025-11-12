SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeletePhoneCard](@PhoneCardId INT)
AS
     BEGIN
         DELETE FROM [dbo].PhoneCards
         WHERE PhoneCardId = @PhoneCardId;
     END;
GO