{
module Parse (parse) where

import Assembly
import qualified Scan as S
}

%name parse
%tokentype { S.Token }
%error { parseError }

%token
  newline { S.Newline }
  ',' { S.Comma }
  int { S.Int $$ }
  key { S.Key $$ }
  drum { S.Drum $$ }
  label { S.Label $$ }
  '::' { S.GlobalLabel }
  note { S.Note }
  dnote { S.DNote }
  rest { S.Rest }
  notetype { S.NoteType }
  dspeed { S.DSpeed }
  octave { S.Octave }
  vibrato { S.Vibrato }
  duty { S.Duty }
  stereopanning { S.StereoPanning }
  pitchbend { S.PitchBend }
  tempo { S.Tempo }
  loopchannel { S.LoopChannel }
  callchannel { S.CallChannel }
  endchannel { S.EndChannel }
  togglecall { S.ToggleCall }

%%

-- A file that can optionally start with a newline
File :: { [AsmInstruction] }
     : Line File1 { $1 : $2 }
     | File1 { $1 }

-- A file that must start with a newline
File1 :: { [AsmInstruction] }
      : Newlines Line File1 { $2 : $3 }
      | Newlines { [] }
      | { [] }

-- One or more newlines
Newlines : newline { () }
         | newline Newlines { () }

Line :: { AsmInstruction }
     : Inst { Right $1 }
     | Control { Left $1 }

Inst :: { Instruction Int }
     : note key ',' int { Note $2 $4 }
     | dnote int ',' drum { DNote $2 $4 }
     | rest int { Rest $2 }
     | notetype int ',' int ',' int { NoteType $2 $4 $6 }
     | dspeed int { DSpeed $2 }
     | octave int { Octave $2 }
     | vibrato int ',' int ',' int { Vibrato $2 $4 $6 }
     | duty int { Duty $2 }
     | stereopanning int { StereoPanning $2 }
     | pitchbend int ',' int { PitchBend $2 $4 }
     | tempo int ',' int { Tempo $2 $4 }

Control :: { Control String }
        : label '::' { Label $1 }
        | loopchannel int ',' label { LoopChannel $2 $4 }
        | callchannel label { CallChannel $2 }
        | endchannel { EndChannel }
        | togglecall { ToggleCall }

{

parseError :: [S.Token] -> a
parseError _ = error "Parse error"

}