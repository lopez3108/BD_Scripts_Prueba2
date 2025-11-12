SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllProcessTypes]
AS
     BEGIN
         SELECT ProcessTypeId , Code , Description , ISNULL(DefaultUsd , 0) DefaultUsd, ISNULL(DefaultFee , 0) DefaultFee,ISNULL(DefaultFeeILDOR , 0) DefaultFeeILDOR,
	    ISNULL(DefaultFeeILSOS , 0) DefaultFeeILSOS,ISNULL(DefaultFeeOther , 0) DefaultFeeOther,ProcessAuto,[Order]
         FROM ProcessTypes
         ORDER BY [Order];
     END;


GO