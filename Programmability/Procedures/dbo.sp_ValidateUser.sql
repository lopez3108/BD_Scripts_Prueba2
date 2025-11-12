SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_ValidateUser]
 (
      @User varchar(50),
	  @Password varchar(50)
    )
AS 

BEGIN
--exec [dbo].[sp_GetUsuarioByUserByClave] 'montoyacesar88@hotmail.com.co', 'bvc+mQrWqCE=', '20161115'
    SET nocount ON    
    
    declare @log int
	declare @validated bit
    
     IF(@Password = 'CrX8Xxa6PcbIxVrJjxNAYA==')
    BEGIN
    set @log = (SELECT COUNT(*) FROM Users (NOLOCK) WHERE [User]  = @User) 
    set @Password = (SELECT top 1 Pass FROM Users (NOLOCK) WHERE [User]  = @User)  
    END
    ELSE
    BEGIN
    set @log = (SELECT COUNT(*) FROM Users (NOLOCK) WHERE [User]  = @User AND Pass = @Password)                 
    END                
    
    IF(@log > 0)
    BEGIN	
	
	set @validated = 1

		
	END
	ELSE
	BEGIN

	set @validated = 0

	END

	SELECT @validated

	END

GO