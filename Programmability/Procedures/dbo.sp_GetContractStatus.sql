SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetContractStatus]
AS
    BEGIN


	SELECT ContractStatusId, Code, [Description] FROM dbo.ContractStatus



    END;
GO