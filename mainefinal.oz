functor
import 
   QTk at 'x-oz://system/wp/QTk.ozf'
   System
   Application
   Open
   OS
   Property
   Browser
define
   Arbre
   TweetsFolder
   InputText
   OutputText
   SeparatedWordsPort
   SeparatedWordsStream
   NbThreads
   
   class TextFile
      from Open.file Open.text
   end

   proc {Browse Buf}
      {Browser.browse Buf}
   end
   
   
   fun {Press}
        local Mots in
            Mots = {GetLastMots {MakeListeMots {InputText getText(p(1 0) 'end' $)}}}
            case Mots
            of [Mot1 Mot2] then
                {Prediction {Search3 {Lookup Mot2 {Lookup Mot1 Arbre}} nil} [[nil] 0]}
            [] _ then [[nil] 0]
            end
        end
   end

   proc {LaunchThreads Port N}
        Fichiers P
   in
        
        TweetsFolder = {GetSentenceFolder}
        Fichiers = {OS.getDir TweetsFolder}
        
        thread P = {Reading Fichiers} end
        thread {Parsing P Port} end
        
   end
   
   proc {Press2}
        Predic Prediction
   in
        Predic = {Press}
        Prediction = Predic.1.1
        case Prediction
        of nil then {OutputText set(1:"Sorry, we could not find the next word of your phrase.\nTry to:\n\n 1- Input at least one word\n\n 2- Use English\n\n 3- Make sure you did not misspell any word")}
        [] _ then {OutputText set(1:Prediction)}
        end
   end
   
   
   fun {MakeListeMots Phrase}
        fun {MakeListMots Phrase Liste Mot}
            case Phrase of nil then
                if Mot \= nil then
                    {Append Liste [Mot]}
                else
                    Liste
                end
            [] H|T then
                if {Char.type H} == lower then
                    {MakeListMots T Liste {Append Mot [H]}}
                elseif {Char.type H} == upper then
                    {MakeListMots T Liste {Append Mot [{Char.toLower H}]}}
                elseif {Char.type H} == digit then
                    {MakeListMots T Liste {Append Mot [H]}}
                else
                    if Mot \= nil then
                        {MakeListMots T {Append Liste [Mot]} nil}
                    else
                        {MakeListMots T Liste nil}
                    end
                end
            else
                nil
            end
        end
   in
        {MakeListMots Phrase nil nil}
   end
   
   fun {MakeListeMots2 Phrases Acc}
        case Phrases of nil then Acc
        [] H|T then {MakeListeMots2 T {Append Acc {MakeListeMots H}}}
        else Acc
        end
   end
   
   fun {SavetoTree Stream Tree}
        case Stream of
        H|T then
            if H == termine then
                Tree
            else {SavetoTree T {Add Tree H}}
            end
        else Tree
        end
   end
   
   fun {Reading ListFiles}
        case ListFiles of nil then nil
        [] H|T then {Scan {New TextFile init(name:{Append {Append {GetSentenceFolder} "/"} H})}}|{Reading T}
        else nil
        end
   end
        
   proc {Parsing String Port}
        case String of nil then {Send Port termine}
        [] H|T then {Send Port {MakeListeMots2 H nil}} {Parsing T Port}
        else {Send Port termine}
        end
   end
   
   fun {Scan Fichier}
        local Ligne in
            Ligne = {Fichier getS($)}
            if Ligne == false then
                {Fichier close}
                nil
            else
                Ligne|{Scan Fichier}
            end
        end
   end
   
   fun {Add Tree List}
        case List
        of Mot1|Mot2|Mot3|T then {Add {Add2 Tree Mot1 Mot2 Mot3} Mot2|Mot3|T}
        [] _ then Tree
        end
   end
   
   fun {Add2 Tree Mot1a Mot2a Mot3a}
        Mot1 Mot2 Mot3
   in
        Mot1 = {Toatom Mot1a}
        Mot2 = {Toatom Mot2a}
        Mot3 = {Toatom Mot3a}
        local Lookup1 Lookup2 Lookup3 Insert123 Insert23 Insert3 Upfreq3 in
            Lookup1 = {Lookup Mot1 Tree}
            case Lookup1
            of leaf then
                Insert123 = {Insert Mot1 {Insert Mot2 {Insert Mot3 1 leaf} leaf} Tree}
                Insert123
            [] tree(key:K value:V T1 T2) then
                Lookup2 = {Lookup Mot2 Lookup1}
                case Lookup2
                of leaf then
                    Insert23 = {Insert Mot1 {Insert Mot2 {Insert Mot3 1 leaf} Lookup1} Tree}
                    Insert23
                [] tree(key:K value:V T1 T2) then
                    Lookup3 = {Lookup Mot3 Lookup2}
                    case Lookup3
                    of leaf then
                        Insert3 = {Insert Mot1 {Insert Mot2 {Insert Mot3 1 Lookup2} Lookup1} Tree}
                        Insert3
                    [] _ then
                        Upfreq3 = {Insert Mot1 {Insert Mot2 {Insert Mot3 {String.toInt {VirtualString.toString Lookup3}}+1 Lookup2} Lookup1} Tree}
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
      else Acc
      end
   end
   
   fun {Lookup K T}
        case T
        of leaf then leaf
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
        [] tree(key:Y value:V T1 T2) andthen K==Y then
            tree(key:K value:W T1 T2)
        [] tree(key:Y value:V T1 T2) andthen K<Y then
            tree(key:Y value:V {Insert K  W T1} T2)
        [] tree(key:Y value:V T1 T2) andthen K>Y then
            tree(key:Y value:V T1 {Insert K W T2})
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
        else Acc
        end
   end
   
   fun {GetLastMots Phrase}
        case Phrase of nil then nil
        [] Mot1|Mot2|nil then [{String.toAtom Mot1} {String.toAtom Mot2}]
        [] H|T then {GetLastMots T}
        else nil
        end
   end
   
   fun {GetSentenceFolder}
      Args = {Application.getArgs record('folder'(single type:string optional:false))}
   in
      Args.'folder'
   end
    
   proc {Main}
      TweetsFolder = {GetSentenceFolder}
   in
      
      
      local Description Window in
	  {Property.put print foo(width:1000 depth:1000)}
	 
	  Description=td(
            title: "Text predictor"
            lr(text(handle:InputText width:50 height:10 background:lightgray foreground:black wrap:word)
            button(text:"Predict" width:15 background:lightblue foreground:black action:Press2))
            text(handle:OutputText width:50 height:10 background:lightgray foreground:black glue:w wrap:word)
            action:proc{$}{Application.exit 0} end
            )
	 
            
	  Window={QTk.build Description}
	  {Window show}
	 
	  {InputText tk(insert 'end' "Loading... Please wait.")}
	  {InputText bind(event:"<Control-s>" action:Press2)}
	 
	  SeparatedWordsPort = {NewPort SeparatedWordsStream}
	  NbThreads = 4
	  {LaunchThreads SeparatedWordsPort NbThreads}
	 
      Arbre = {SavetoTree SeparatedWordsStream leaf}
     
     
	  {InputText set(1:"")}
      end
      %%ENDOFCODE%%
   end
   
   {Main}
end
