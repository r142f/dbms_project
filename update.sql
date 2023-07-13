-- ChangePieceYear
-- read committed
UPDATE Pieces
SET PieceYear = 1839
WHERE ISWC = 'T-932.532.733-1';

-- ChangePieceName
-- read committed
UPDATE Pieces
SET PieceName = 'Prelude in B Minor (Op. 28 No. 6)'
WHERE ISWC = 'T-932.532.733-1';

-- ChangeComposerName
-- read committed
UPDATE Composers
SET ComposerName = 'Frederic Chopin'
WHERE ComposerId = 1;

-- ChangeInstrumentName
-- read committed
UPDATE Instruments
SET InstrumentName = 'piano'
WHERE InstrumentName = 'pano';

-- ChangeFormName
-- read committed
UPDATE Forms
SET FormName = 'concerto'
WHERE FormName = 'concert';

-- ChangeTempoName
-- read committed
UPDATE Tempos
SET TempoName = 'largo'
WHERE TempoName = 'large';

-- ChangePieceTempo
-- read committed
UPDATE Pieces
SET TempoId = (
    SELECT TempoId
    FROM Tempos
    WHERE TempoName = 'largo'
  )
WHERE ISWC = 'T-932.532.733-1';

-- read committed
CREATE OR REPLACE FUNCTION UpdateISWCBeforeHandler()
  RETURNS TRIGGER
  AS $$
BEGIN
  IF OLD.ISWC IS NOT DISTINCT FROM NEW.ISWC THEN
    RETURN new;
  END IF;

  SET constraints CP_P_ISWC_FK2,
    C_CP_ComposerId_ISWC_FK,
    P_CP_ISWC_ComposerId_FK1,
    IP_P_ISWC_FK2,
    P_IP_ISWC_InstrumentId_FK2 DEFERRED;

  UPDATE ComposersPieces
  SET ISWC = NEW.ISWC
  WHERE ISWC = OLD.ISWC;

  UPDATE InstrumentsPieces
  SET ISWC = NEW.ISWC
  WHERE ISWC = OLD.ISWC;

  UPDATE Composers
  SET ISWC = NEW.ISWC
  WHERE ISWC = OLD.ISWC;

  RETURN new;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER UpdateISWCBeforeTrigger
BEFORE UPDATE ON Pieces
FOR EACH ROW
EXECUTE PROCEDURE UpdateISWCBeforeHandler();

-- read committed
CREATE OR REPLACE PROCEDURE ChangeComposersFirstISWC(_ISWC Pieces.ISWC%TYPE)
  AS $$
BEGIN
  UPDATE Composers c
  SET ISWC = (
      SELECT ISWC
      FROM ComposersPieces
      WHERE ComposerId = c.ComposerId
        AND ISWC <> _ISWC
      LIMIT 1
    )
  WHERE ISWC = _ISWC
    AND EXISTS (
      SELECT ISWC
      FROM ComposersPieces
      WHERE ComposerId = c.ComposerId
        AND ISWC <> _ISWC
    );
END;
$$
LANGUAGE plpgsql;

-- repeatable read
CREATE OR REPLACE PROCEDURE UpdatePieceComposers(_ISWC Pieces.ISWC%TYPE, _ComposersIds integer[])
  AS $$
DECLARE
  CId Composers.ComposerId%TYPE;
BEGIN
  CALL ChangeComposersFirstISWC(_ISWC);

  SET constraints C_CP_ComposerId_ISWC_FK,
    P_CP_ISWC_ComposerId_FK1 DEFERRED;

  UPDATE Pieces
  SET ComposerId = _ComposersIds[1]
  WHERE ISWC = _ISWC;

  DELETE FROM ComposersPieces
  WHERE ISWC = _ISWC;

  FOREACH CId IN ARRAY _ComposersIds LOOP
    INSERT INTO ComposersPieces (ComposerId, ISWC)
    VALUES (CId, _ISWC);
  END LOOP;
END;
$$
LANGUAGE plpgsql;

-- repeatable read
CREATE OR REPLACE PROCEDURE UpdatePieceInstruments(_ISWC Pieces.ISWC%TYPE, _IIdCountPairs integer[2][])
  AS $$
DECLARE
  IIdCountPair integer[2];
BEGIN
  SET constraints P_IP_ISWC_InstrumentId_FK2 DEFERRED;

  UPDATE Pieces
  SET InstrumentId = _IIdCountPairs[1][1]
  WHERE ISWC = _ISWC;

  DELETE FROM InstrumentsPieces
  WHERE ISWC = _ISWC;

  FOREACH IIdCountPair SLICE 1 IN ARRAY _IIdCountPairs LOOP
    INSERT INTO InstrumentsPieces (InstrumentId, ISWC, InstrumentCount)
    VALUES (IIdCountPair[1], _ISWC, IIdCountPair[2]);
  END LOOP;
END;
$$
LANGUAGE plpgsql;

-- read committed
CREATE OR REPLACE PROCEDURE DeleteComposer(_ComposerId Composers.ComposerId%TYPE)
  AS $$
BEGIN
  UPDATE Pieces p
  SET ComposerId = (
      SELECT ComposerId
      FROM ComposersPieces
      WHERE ComposerId <> _ComposerId
        AND ISWC = p.ISWC
      LIMIT 1
    )
  WHERE ComposerId = _ComposerId
    AND EXISTS (
      SELECT ComposerId
      FROM ComposersPieces
      WHERE ComposerId <> _ComposerId
        AND ISWC = p.ISWC
    );

  SET constraints C_CP_ComposerId_ISWC_FK,
    P_CP_ISWC_ComposerId_FK1,
    P_IP_ISWC_InstrumentId_FK2 DEFERRED;

  DELETE FROM ComposersPieces
  WHERE ComposerId = _ComposerId;

  DELETE FROM InstrumentsPieces
  WHERE ISWC IN (
      SELECT ISWC
      FROM Pieces
      WHERE ComposerId = _ComposerId
    );

  DELETE FROM Pieces
  WHERE ComposerId = _ComposerId;
END;
$$
LANGUAGE plpgsql;

-- read committed
CREATE OR REPLACE FUNCTION DeletePieceBeforeHandler()
  RETURNS TRIGGER
  AS $$
BEGIN
  CALL ChangeComposersFirstISWC(OLD.ISWC);

  SET constraints C_CP_ComposerId_ISWC_FK,
    P_CP_ISWC_ComposerId_FK1,
    P_IP_ISWC_InstrumentId_FK2 DEFERRED;

  DELETE FROM ComposersPieces
  WHERE ISWC = OLD.ISWC;

  DELETE FROM InstrumentsPieces
  WHERE ISWC = OLD.ISWC;

  DELETE FROM Composers
  WHERE ISWC = OLD.ISWC;

  RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER DeletePieceBeforeTrigger
BEFORE DELETE ON Pieces
FOR EACH ROW
EXECUTE PROCEDURE DeletePieceBeforeHandler();

-- UpdatePieceComposers
-- repeatable read
CALL UpdatePieceComposers('T-919.739.204-4', ARRAY [2, 4]);

-- UpdatePieceInstruments
-- repeatable read
CALL UpdatePieceInstruments(
  'T-919.739.204-4',
  ARRAY [ARRAY [1, 2], ARRAY [2, 1]]);
  
-- DeleteComposer
-- read committed
CALL DeleteComposer(1);

-- ChangePieceISWC
-- read committed
UPDATE Pieces
SET ISWC = 'T-999.999.999-9'
WHERE ISWC = 'T-072.457.235-3';

-- DeletePiece
-- read committed
DELETE FROM Pieces
WHERE ISWC = 'T-919.739.204-4';
