SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveTemplateContract] (

@TemplateContractId INT = NULL,
@TitleTemplateContract VARCHAR(100) = NULL,
@TemplateContract VARCHAR(MAX) = NULL
  
  )

AS

BEGIN

  IF (@TemplateContractId IS NULL)
  BEGIN

    INSERT INTO TemplatesContract (TitleTemplateContract, TemplateContract)
    VALUES (@TitleTemplateContract, @TemplateContract);  


    SELECT
      @@IDENTITY


  END

  UPDATE TemplatesContract    
  SET TitleTemplateContract = @TitleTemplateContract
     ,TemplateContract = @TemplateContract

  WHERE TemplateContractId = @TemplateContractId

  SELECT
    @TemplateContractId

END
GO