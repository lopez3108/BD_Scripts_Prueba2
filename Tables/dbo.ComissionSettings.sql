CREATE TABLE [dbo].[ComissionSettings] (
  [ComissionSettingId] [int] IDENTITY,
  [CitySticker] [decimal](18, 2) NOT NULL CONSTRAINT [DF_ComissionSettings_CitySticker] DEFAULT (0),
  [PlateSticker] [decimal](18, 2) NOT NULL CONSTRAINT [DF_ComissionSettings_PlateSticker] DEFAULT (0),
  [ParkingTicket] [decimal](18, 2) NOT NULL CONSTRAINT [DF_ComissionSettings_ParkingTicket1] DEFAULT (0),
  [ParkingTicketCard] [decimal](18, 2) NOT NULL CONSTRAINT [DF_ComissionSettings_TitlesAndPlates1] DEFAULT (0),
  [TitlesAndPlates] [decimal](18, 2) NOT NULL CONSTRAINT [DF_ComissionSettings_TitlesAndPlates] DEFAULT (0),
  [TitlesAndPlatesManual] [decimal](18, 2) NOT NULL CONSTRAINT [DF_ComissionSettings_TitlesAndPlates1_1] DEFAULT (0),
  [Trp730] [decimal](18, 2) NOT NULL CONSTRAINT [DF_ComissionSettings_TitlesAndPlatesManual1] DEFAULT (0),
  [Financing] [decimal](18, 2) NOT NULL CONSTRAINT [DF_ComissionSettings_TitlesAndPlatesManual1_1] DEFAULT (0),
  [Telephones] [decimal](18, 2) NOT NULL CONSTRAINT [DF_ComissionSettings_Telephones] DEFAULT (0),
  [Notary] [decimal](18, 2) NOT NULL CONSTRAINT [DF_ComissionSettings_Telephones1] DEFAULT (0),
  [Lendify] [decimal](18, 2) NOT NULL DEFAULT (0),
  [LendifyCompany] [decimal](18, 2) NOT NULL CONSTRAINT [DF_ComissionSettings_LendifyCompany] DEFAULT (0),
  [Tickets] [decimal](18, 2) NOT NULL DEFAULT (0),
  [NewPolicy] [decimal](18, 2) NOT NULL DEFAULT (0),
  [MonthlyPayment] [decimal](18, 2) NOT NULL DEFAULT (0),
  [RegistrationRelease] [decimal](18, 2) NOT NULL DEFAULT (0),
  [Endorsement] [decimal](18, 2) NULL,
  [PolicyRenewal] [decimal](18, 2) NULL,
  CONSTRAINT [PK_ComissionSettings] PRIMARY KEY CLUSTERED ([ComissionSettingId])
)
ON [PRIMARY]
GO