declare
   fun {Add Tree List}
        case List
        of Mot1|Mot2|Mot3|T then {Add {Add2 Tree Mot1 Mot2 Mot3} Mot2|Mot3|T}
        [] _ then Tree
        end
   end
   
   fun {Add2 Tree Mot1 Mot2 Mot3}
        Mot1 = {Toatom Mot1}
        Mot2 = {Toatom Mot2}
        Mot3 = {Toatom Mot3}
        local Lookup1 Lookup2 Lookup3 Insert123 Insert23 Insert3 Upfreq3 in
            Lookup1 = {Lookup Mot1 Tree}
            case Lookup1
            of notfound then
                Insert123 = {Insert Mot1 {Insert Mot2 {Insert Mot3 1 leaf} leaf} Tree}
                Insert123
            [] tree(key:K value :V T1 T2) then
                Lookup2 = {Lookup Mot2 Lookup1}
                case Lookup2
                of notfound then
                    Insert23 = {Insert Mot1 {Insert Mot2 {Insert Mot3 1 leaf} Lookup1} Tree}
                    Insert23
                [] tree(key:K value :V T1 T2) then
                    Lookup3 = {Lookup Mot3 Lookup2}
                    case Lookup3
                    of notfound then
                        Insert3 = {Insert Mot1 {Insert Mot2 {Insert Mot3 1 Lookup2} Lookup1} Tree}
                        Insert3
                    [] tree(key:K value :V T1 T2) then
                        Upfreq3 = {Insert Mot1 {Insert Mot2 {Insert Mot3 {String.toInt {VirtualString.toString Lookup3}}+1 Lookup2} Lookup1} Tree} %%% modifiable???
                        Upfreq3
                    end
                end
            end
        end
   end
   
   fun {Toatom Word}
        if {Atom.is Word} then Word
        else {String.toAtom Word}
        end
   end
   
   fun {Search3 Tree Acc}
      case Tree
      of leaf then Acc
      [] tree(key:K value:V T1 T2) then
            local A B C in
                A = {List.append Acc [[[K] V]]}
                B = {Search3 T1 A}
                C = {Search3 T2 B}
                C
            end
      end
   end

   fun {Lookup K T}
        case T
        of leaf then notfound
        [] tree(key:Y value:V T1 T2) andthen K==Y then
            V
        [] tree(key:Y value:V T1 T2) andthen K<Y then
            {Lookup K T1}
        [] tree(key:Y value:V T1 T2) andthen K>Y then
            {Lookup K T2}
        end
   end

   fun {Insert K W T}
        case T
        of leaf then tree(key:K value:W leaf leaf)
        [] tree(key:Y value:V T1 T2) andthen K==Y then % Replace old value
            tree(key:K value:W T1 T2)
        [] tree(key:Y value:V T1 T2) andthen K<Y then
            tree(key:Y value:V {Insert K  W T1} T2)
        [] tree(key:Y value:V T1 T2) andthen K>Y then
            tree(key:Y value:V T1 {Insert K W T2})
        end
   end

{Browse {Add leaf [ces mots sont tous super beau ces mots ont de la chance ils ont de la main de tu le ou tu te manges du chocolat au lait du mots ont sont du]}}
