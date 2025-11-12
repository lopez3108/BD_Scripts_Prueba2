SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveProviderEls] (@ProviderElsId INT = NULL,
@Name VARCHAR(50),
@Fee1Default DECIMAL(18, 2),
@DefaultUsd DECIMAL(18, 2),
@FeeELS DECIMAL(18, 2),
@FeeElsTrp DECIMAL(18, 2) = NULL,
@FeeElsSale DECIMAL(18, 2),
@FeeElsTrpSale DECIMAL(18, 2) = NULL,
@FeeCollect DECIMAL(18, 2) = NULL,
@IdSaved INT OUTPUT)
AS
BEGIN
  IF (@ProviderElsId IS NULL)
  BEGIN
    INSERT INTO [dbo].[ProvidersEls] (Name,
    Fee1Default,
    DefaultUsd,
    FeeELS,
    FeeELSTrp,
    FeeElsSale,
    FeeElsTrpSale,
    FeeCollect)
      VALUES (@Name, @Fee1Default, @DefaultUsd, @FeeELS, @FeeElsTrp,@FeeElsSale,@FeeElsTrpSale, @FeeCollect);
    SET @IdSaved = @@IDENTITY;
  END;
  ELSE
  BEGIN
    UPDATE [dbo].[ProvidersEls]
    SET Name = @Name
       ,Fee1Default = @Fee1Default
       ,DefaultUsd = @DefaultUsd
       ,FeeELS = @FeeELS
       ,FeeELSTrp = @FeeElsTrp
       ,FeeElsSale = @FeeElsSale
       ,FeeElsTrpSale = @FeeElsTrpSale
       ,FeeCollect = @FeeCollect
    WHERE ProviderElsId = @ProviderElsId;
    SET @IdSaved = @ProviderElsId
  END;
END;
GO