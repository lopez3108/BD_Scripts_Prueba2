SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveAgenda] (@AgendaId INT = NULL,
--@AgendaStatusId INT,
@AgendaStatusCode VARCHAR(5),
@Description VARCHAR(100),
@FileIdNameAgendaCopy VARCHAR(200) = NULL,
@CreatedBy INT = NULL,
@DelegateTo INT = NULL,
@CreationDate DATETIME = NULL,
@IdSaved INT OUTPUT,
@UpdateBy INT = NULL,
@UpdateOn DATETIME = NULL,
@DelegateBy INT = NULL)
AS

DECLARE @AgendaStatusId INT
  SET @AgendaStatusId = (SELECT [as].AgendaStatusId FROM AgendaStatus [as] WHERE [as].Code = @AgendaStatusCode )

BEGIN
  IF (@AgendaId IS NULL)
  BEGIN
    INSERT INTO [dbo].Agendas (AgendaStatusId, Description, CreationDate, CreatedBy, FileIdNameAgendaCopy )
                        VALUES (@AgendaStatusId, @Description, @CreationDate, @CreatedBy,@FileIdNameAgendaCopy);
     SET @IdSaved = @@IDENTITY;

  END;
  ELSE
  BEGIN
    UPDATE [dbo].Agendas
    SET AgendaStatusId = @AgendaStatusId
       ,Description = @Description  
       ,FileIdNameAgendaCopy  = @FileIdNameAgendaCopy
	   ,DelegateTo = @DelegateTo
	   ,UpdateBy =@UpdateBy
	   ,UpdateOn=@UpdateOn
	   ,DelegateBy = @DelegateBy
    WHERE AgendaId = @AgendaId;
    SET @IdSaved = @AgendaId;

	--if(@DelegateTo is not null)
	-- BEGIN
	--  SET @AgendaStatusId = (SELECT [as].AgendaStatusId FROM AgendaStatus [as] WHERE [as].Code = 'C01' )

	--	INSERT INTO [dbo].Agendas (AgendaStatusId, Description, CreationDate, CreatedBy, FileIdNameAgendaCopy )
 --                       VALUES (@AgendaStatusId, @Description, @CreationDate, @DelegateTo,@FileIdNameAgendaCopy);
	--	END;


  END;


END;
GO