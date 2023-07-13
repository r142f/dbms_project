CREATE TYPE note AS enum (
  'A',
  'A-sharp',
  'B-flat',
  'B',
  'B-sharp',
  'C-flat',
  'C',
  'C-sharp',
  'D-flat',
  'D',
  'D-sharp',
  'E-flat',
  'E',
  'E-sharp',
  'F-flat',
  'F',
  'F-sharp',
  'G-flat',
  'G',
  'G-sharp',
  'A-flat'
);

CREATE TYPE modus AS enum ('minor', 'major');

CREATE TABLE Forms (
  FormId integer GENERATED ALWAYS AS IDENTITY,
  FormName varchar(63) NOT NULL,
  CONSTRAINT F_FormId_PK PRIMARY KEY (FormId),
  CONSTRAINT F_FormName_K1 UNIQUE (FormName)
);

CREATE TABLE Tempos (
  TempoId integer GENERATED ALWAYS AS IDENTITY,
  TempoName varchar(63) NOT NULL,
  TempoMinBPM integer NOT NULL,
  TempoMaxBPM integer NOT NULL,
  CONSTRAINT T_TempoId_PK PRIMARY KEY (TempoId),
  CONSTRAINT T_TempoName_K1 UNIQUE (TempoName),
  CONSTRAINT T_TempoMinBPM_GT_0_LET_200 CHECK (
    TempoMinBPM BETWEEN 1 AND 200
  ),
  CONSTRAINT T_TempoMaxBPM_GT_0_LET_200 CHECK (
    TempoMaxBPM BETWEEN 1 AND 200
  ),
  CONSTRAINT T_TempoMinBPM_LET_TempoMaxBPM CHECK (TempoMinBPM <= TempoMaxBPM)
);

CREATE TABLE Styles (
  StyleId integer GENERATED ALWAYS AS IDENTITY,
  StyleName varchar(63) NOT NULL,
  CONSTRAINT S_StyleId_PK PRIMARY KEY (StyleId),
  CONSTRAINT S_StyleName_K1 UNIQUE (StyleName)
);

CREATE TABLE Pieces (
  ISWC char(15) NOT NULL,
  PieceName varchar(511) NULL,
  PieceYear integer NULL,
  ComposerId integer NOT NULL,
  InstrumentId integer NOT NULL,
  TonalityTonic note NOT NULL,
  TonalityModus modus NOT NULL,
  FormId integer NOT NULL,
  TempoId integer NOT NULL,
  StyleId integer NOT NULL,
  CONSTRAINT P_ISWC_PK PRIMARY KEY (ISWC),
  CONSTRAINT P_F_FormId_FK3 FOREIGN KEY (FormId) REFERENCES Forms (FormId),
  CONSTRAINT P_T_Tempos_FK4 FOREIGN KEY (TempoId) REFERENCES Tempos (TempoId),
  CONSTRAINT P_S_Styles_FK5 FOREIGN KEY (StyleId) REFERENCES Styles (StyleId)
);

CREATE TABLE Composers (
  ComposerId integer GENERATED ALWAYS AS IDENTITY,
  ComposerName varchar(255) NOT NULL,
  ISWC char(15) NOT NULL,
  CONSTRAINT C_ComposerId_PK PRIMARY KEY (ComposerId)
);

CREATE TABLE ComposersPieces (
  ComposerId integer NOT NULL,
  ISWC char(15) NOT NULL,
  CONSTRAINT CP_ComposerId_ISWC_PK PRIMARY KEY (ComposerId, ISWC),
  CONSTRAINT CP_C_ComposerId_FK1 FOREIGN KEY (ComposerId) REFERENCES Composers (ComposerId) DEFERRABLE INITIALLY immediate,
  CONSTRAINT CP_P_ISWC_FK2 FOREIGN KEY (ISWC) REFERENCES Pieces (ISWC) DEFERRABLE INITIALLY immediate
);

ALTER TABLE Composers
ADD CONSTRAINT C_CP_ComposerId_ISWC_FK FOREIGN KEY (ComposerId, ISWC) REFERENCES ComposersPieces (ComposerId, ISWC) DEFERRABLE INITIALLY immediate;

ALTER TABLE Pieces
ADD CONSTRAINT P_CP_ISWC_ComposerId_FK1 FOREIGN KEY (ISWC, ComposerId) REFERENCES ComposersPieces (ISWC, ComposerId) DEFERRABLE INITIALLY immediate;

CREATE TABLE Instruments (
  InstrumentId integer GENERATED ALWAYS AS IDENTITY,
  InstrumentName varchar(63) NOT NULL,
  CONSTRAINT I_InstrumentId_PK PRIMARY KEY (InstrumentId),
  CONSTRAINT I_InstrumentName_K1 UNIQUE (InstrumentName)
);

CREATE TABLE InstrumentsPieces (
  InstrumentId integer NOT NULL,
  ISWC char(15) NOT NULL,
  InstrumentCount integer NOT NULL,
  CONSTRAINT IP_InstrumentId_ISWC_PK PRIMARY KEY (InstrumentId, ISWC),
  CONSTRAINT IP_I_InstrumentId_FK1 FOREIGN KEY (InstrumentId) REFERENCES Instruments (InstrumentId),
  CONSTRAINT IP_P_ISWC_FK2 FOREIGN KEY (ISWC) REFERENCES Pieces (ISWC) DEFERRABLE INITIALLY immediate
);

ALTER TABLE Pieces
ADD CONSTRAINT P_IP_ISWC_InstrumentId_FK2 FOREIGN KEY (ISWC, InstrumentId) REFERENCES InstrumentsPieces (ISWC, InstrumentId) DEFERRABLE INITIALLY immediate;

-- GetPiecesInfoAggrByISWC
CREATE UNIQUE INDEX ON Pieces USING btree (ISWC);

-- GetPiecesCountByComposerId
CREATE UNIQUE INDEX ON Pieces USING btree (ComposerId, ISWC);

-- GetPiecesInfoAggrByISWC
CREATE UNIQUE INDEX ON Pieces USING btree (FormId, ISWC);

-- GetPiecesInfoWithInstrumentName
CREATE UNIQUE INDEX ON Instruments USING btree (InstrumentName, InstrumentId);

-- GetPiecesInfoAggrByISWC
CREATE UNIQUE INDEX ON Instruments USING btree (InstrumentId, InstrumentName);

-- GetPiecesInfoByFormName
CREATE UNIQUE INDEX ON Forms USING btree (FormName, FormId);

-- GetPiecesInfoAggrByISWC
CREATE UNIQUE INDEX ON Forms USING btree (FormId, FormName);

-- GetPiecesInfoByTempoName
CREATE UNIQUE INDEX ON Tempos USING btree (TempoName, TempoId);

-- GetPiecesInfoAggrByISWC
CREATE UNIQUE INDEX ON Tempos USING btree (TempoId, TempoName);

-- GetPiecesInfoByStyleName
CREATE UNIQUE INDEX ON Styles USING btree (StyleName, StyleId);

-- GetPiecesInfoAggrByISWC
CREATE UNIQUE INDEX ON Styles USING btree (StyleId, StyleName);

-- GetPiecesInfoWithInstrumentName
CREATE UNIQUE INDEX ON Instruments USING btree (InstrumentName, InstrumentId);
-- GetPiecesInfoAggrByISWC
CREATE UNIQUE INDEX ON Instruments USING btree (InstrumentId, InstrumentName);

-- GetPiecesCountByComposerId
CREATE UNIQUE INDEX ON Composers USING btree (ComposerId, ComposerName);

-- GetPiecesInfoAggrWithComposerId
CREATE UNIQUE INDEX ON ComposersPieces USING btree (ComposerId, ISWC);

-- GetPiecesInfoAggrByISWC
CREATE UNIQUE INDEX ON ComposersPieces USING btree (ISWC, ComposerId);

-- GetPiecesInfoByInstrumentName
CREATE UNIQUE INDEX ON InstrumentsPieces USING btree (InstrumentId, ISWC, InstrumentCount);

-- GetPiecesInfoAggrByISWC
CREATE UNIQUE INDEX ON InstrumentsPieces USING btree (ISWC, InstrumentId, InstrumentCount);