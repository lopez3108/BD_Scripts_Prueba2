SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateToken] (@UserId INT, @Token VARCHAR(300),  @ExpirationDate DATETIME)
AS
BEGIN

 INSERT INTO dbo.Access (UserId, Token, ExpirationDate) VALUES (@UserId, @Token, @ExpirationDate) 
 
 SELECT @@IDENTITY


END
GO