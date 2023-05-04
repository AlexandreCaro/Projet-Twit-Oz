declare
proc {SeparerLigne Phrase ?R}
   fun {Fonction Chaine Liste Mots}
      case Chaine
      of nil then
	 if Mots==nil then Liste else {Append Liste [Mots]} end
      [] Head|Tail then
	 case {Char.type Head}
         of lower then {Fonction Tail Liste {Append Mots [Head]}}
         [] upper then {Fonction Tail Liste {Append Mots [Char.toLower Head]}}
         [] digit then {Fonction Tail Liste {Append Mots [Head]}}
	 else
	    if Mots==nil then {Fonction Tail Liste nil}
	    else {Fonction Tail {Append Liste [Mots]} nil}
	    end
	 end
      else
	 nil
      end
   end
in
   R={Fonction Phrase nil nil}
end

fun {GetLastMots Phrase}
   Sentence
in
   Sentence = {SeparerLigne Phrase}
   case Sentence of nil then nil
   [] Mot1|Mot2|nil then [{String.toAtom Mot1} {String.toAtom Mot2}]
   [] H|T then {GetLastMots T}
   end
end

fun {Prediction Liste Acc}
        case Liste
        of nil then Acc
        [] H|T then
            if {String.toInt {VirtualString.toString H.2.1}} > {String.toInt {VirtualString.toString Acc.2.1}} then 
                {Prediction T H}
            elseif {String.toInt {VirtualString.toString H.2.1}} == {String.toInt {VirtualString.toString Acc.2.1}} then
                {Prediction T [{List.append Acc.1 [H.1.1]} H.2.1]}
            else
                {Prediction T Acc}
            end
        end
   end


%{Browse {Prediction [[[maison] 2] [[congress] 3] [[poule] 1] [[you] 4] [[are] 4] [[test] 2]] [[nil] 0]}}

R = {Prediction [[[maison] 2] [[congress] 3] [[poule] 1] [[you] 4] [[are] 4] [[test] 2]] [[nil] 0]}
{Browse [{List.map R.1 VirtualString.toAtom} R.2.1]}
