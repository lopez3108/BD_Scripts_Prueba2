SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_SetFirtsLoginConfiguration]
(
                 @ApplyToManager bit, @ApplyToCashier bit, @ApplyToAdmin bit, @RolId int
)
AS
BEGIN

  UPDATE [dbo].FirstLoginSecurity
    SET ApplyToManager = @ApplyToManager,
    ApplyToCashier = @ApplyToCashier,
    ApplyToAdmin = @ApplyToAdmin
  WHERE RolId = @RolId;
END;
GO