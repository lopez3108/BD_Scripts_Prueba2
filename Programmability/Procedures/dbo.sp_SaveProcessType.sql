SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveProcessType]
(@ProcessTypeId   INT            = NULL,
 @Code            VARCHAR(10),
 @Description     VARCHAR(30),
 @DefaultUsd      DECIMAL(18, 2),
 @DefaultFee      DECIMAL(18, 2),
 @DefaultFeeILDOR DECIMAL(18, 2),
 @DefaultFeeILSOS DECIMAL(18, 2),
 @DefaultFeeOther DECIMAL(18, 2),
 @ProcessAuto     BIT,
 @Order           INT = NULL
)
AS
     BEGIN
         IF(@ProcessTypeId IS NULL)
             BEGIN
                 INSERT INTO [dbo].ProcessTypes
                 (Code,
                  [Description],
                  DefaultUsd,
			   DefaultFee,
                  DefaultFeeILDOR,
                  DefaultFeeILSOS,
                  DefaultFeeOther,
                  ProcessAuto,
                  [Order]
                 )
                 VALUES
                 (@Code,
                  @Description,
                  @DefaultUsd,
			   @DefaultFee,
                  @DefaultFeeILDOR,
                  @DefaultFeeILSOS,
                  @DefaultFeeOther,
                  @ProcessAuto,
                  @Order
                 );
         END;
             ELSE
             BEGIN
                 UPDATE [dbo].ProcessTypes
                   SET
                       Code = @Code,
                       [Description] = @Description,
                       DefaultUsd = @DefaultUsd,
				   DefaultFee = @DefaultFee,
                       DefaultFeeILDOR = @DefaultFeeILDOR,
                       DefaultFeeILSOS = @DefaultFeeILSOS,
                       DefaultFeeOther = @DefaultFeeOther,
                       ProcessAuto = @ProcessAuto,
                       [Order] = @Order
                 WHERE ProcessTypeId = @ProcessTypeId;
         END;
     END;

GO