SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateOther] (@OtherId INT = NULL,
@Name VARCHAR(50),
@AcceptNegative BIT = NULL,
@AcceptDetails BIT = NULL,
@Active BIT = NULL)
AS
BEGIN
  IF (@OtherId IS NULL)
  BEGIN
    INSERT INTO [dbo].[OthersServices] ([Name],
    [AcceptNegative],
    [AcceptDetails],
    Active)
      VALUES (@Name, @AcceptNegative, @AcceptDetails, @Active);
  END;
  ELSE
  BEGIN
    UPDATE [dbo].[OthersServices]
    SET [Name] = @Name
       ,[AcceptNegative] = @AcceptNegative
       ,[AcceptDetails] = @AcceptDetails
       ,[Active] = @Active


    WHERE OtherId = @OtherId;
  END;
END;
GO