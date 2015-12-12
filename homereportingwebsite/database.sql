USE [HomeDataLog]
GO
/****** Object:  Table [dbo].[ChargerData]    Script Date: 12/12/2015 13:50:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ChargerData](
	[pkey] [int] IDENTITY(1,1) NOT NULL,
	[ChargerID] [varchar](25) NULL,
	[DateStamp] [datetime] NULL CONSTRAINT [DF_ChargerData_DateStamp]  DEFAULT (getdate()),
	[ChargingPower] [float] NULL,
	[ChargingTotal] [float] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FullArchive]    Script Date: 12/12/2015 13:50:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FullArchive](
	[EntryDate] [date] NULL,
	[EntryHour] [varchar](5) NULL,
	[avgwatertop] [decimal](38, 6) NULL,
	[maxwatertop] [decimal](18, 2) NULL,
	[avgwaterbase] [decimal](38, 6) NULL,
	[maxwaterbase] [decimal](18, 2) NULL,
	[avgwaterpanel] [decimal](38, 6) NULL,
	[maxwaterpanel] [decimal](18, 2) NULL,
	[avgwhometemp] [decimal](38, 6) NULL,
	[maxhometemp] [decimal](18, 2) NULL,
	[avgmainsc] [decimal](38, 6) NULL,
	[maxmainsc] [decimal](18, 2) NULL,
	[avgsolarc] [decimal](38, 6) NULL,
	[maxsolarc] [decimal](18, 2) NULL,
	[avgbatteryv] [decimal](38, 6) NULL,
	[maxbatteryv] [decimal](18, 2) NULL,
	[avggeneralc] [decimal](38, 6) NULL,
	[maxgeneralc] [decimal](18, 2) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[HomeLogArchive]    Script Date: 12/12/2015 13:50:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HomeLogArchive](
	[pkey] [int] IDENTITY(1,1) NOT NULL,
	[eDate] [datetime] NULL,
	[watertopaverage] [decimal](18, 2) NULL,
	[watertopmax] [decimal](18, 2) NULL,
	[waterbaseaverage] [decimal](18, 2) NULL,
	[waterbasemax] [decimal](18, 2) NULL,
	[waterpanelaverage] [decimal](18, 2) NULL,
	[waterpanelmax] [decimal](18, 2) NULL,
	[hometempaverage] [decimal](18, 2) NULL,
	[hometempmax] [decimal](18, 2) NULL,
	[hometempaverage2] [decimal](18, 2) NULL,
	[hometempmax2] [decimal](18, 2) NULL,
	[hometempaverage3] [decimal](18, 2) NULL,
	[hometempmax3] [decimal](18, 2) NULL,
	[mainscaverage] [decimal](18, 2) NULL,
	[mainscmax] [decimal](18, 2) NULL,
	[solarcaverage] [decimal](18, 3) NULL,
	[solarcmax] [decimal](18, 3) NULL,
	[batteryvaverage] [decimal](18, 3) NULL,
	[batteryvmax] [decimal](18, 3) NULL,
	[generalcaverage] [decimal](18, 3) NULL,
	[generalcmax] [decimal](18, 3) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[HomeLogGeneral]    Script Date: 12/12/2015 13:50:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HomeLogGeneral](
	[pkey] [int] IDENTITY(1,1) NOT NULL,
	[eDate] [datetime] NULL,
	[watertop] [decimal](18, 2) NULL,
	[waterbase] [decimal](18, 2) NULL,
	[waterpanel] [decimal](18, 2) NULL,
	[pumprunning] [tinyint] NULL,
	[hometemp1] [decimal](18, 2) NULL,
	[hometemp2] [decimal](18, 2) NULL,
	[hometemp3] [decimal](18, 2) NULL,
	[solarc] [decimal](18, 2) NULL,
	[offgridc] [decimal](18, 2) NULL,
	[batteryv] [decimal](18, 2) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[IP]    Script Date: 12/12/2015 13:50:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IP](
	[pkey] [int] NOT NULL,
	[LastIP] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MeterReadings]    Script Date: 12/12/2015 13:50:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MeterReadings](
	[pkey] [int] IDENTITY(1,1) NOT NULL,
	[ReadingDate] [datetime] NULL CONSTRAINT [DF_MeterReadings_ReadingDate]  DEFAULT (getdate()),
	[MeterElectric] [bigint] NULL,
	[MeterGas] [bigint] NULL,
	[Notes] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Nest]    Script Date: 12/12/2015 13:50:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Nest](
	[pkey] [int] IDENTITY(1,1) NOT NULL,
	[ReadingDate] [datetime] NULL,
	[HWHours] [time](7) NULL,
	[CHHours] [time](7) NULL
) ON [PRIMARY]

GO
