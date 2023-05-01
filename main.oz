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
   %%% Pour ouvrir les fichiers
   class TextFile
      from Open.file Open.text
   end

   proc {Browse Buf}
      {Browser.browse Buf}
   end
   
   %%% /!\ Fonction testee /!\
   %%% @pre : les threads sont "ready"
   %%% @post: Fonction appellee lorsqu on appuie sur le bouton de prediction
   %%%        Affiche la prediction la plus probable du prochain mot selon les deux derniers mots entres
   %%% @return: Retourne une liste contenant la liste du/des mot(s) le(s) plus probable(s) accompagnee de 
   %%%          la probabilite/frequence la plus elevee. 
   %%%          La valeur de retour doit prendre la forme:
   %%%                  <return_val> := <most_probable_words> '|' <probability/frequence> '|' nil
   %%%                  <most_probable_words> := <atom> '|' <most_probable_words> 
   %%%                                           | nil
   %%%                  <probability/frequence> := <int> | <float>
   fun {Press}
      0
   end
   
    %%% Lance les N threads de lecture et de parsing qui liront et traiteront tous les fichiers
    %%% Les threads de parsing envoient leur resultat au port Port
   proc {LaunchThreads Port N}
        % TODO
        %% Slide 44 page 22 Cours 8-9
        %% Prod est la fonction Reading et Disp est la fonction Parsing
      skip
   end
   
   %%% Ajouter vos fonctions et procédures auxiliaires ici

   proc {SeparerLigne Phrase ?R}
      local Fonction
      in
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

   fun {Reading ListFiles}
      case ListFiles of nil then nil
      [] H|T then {Scan H}|{Reading T}
      end
   end

   proc {Parsing String Port}
      case String of nil then nil
      [] H|T then {Send Port {SeparerLigne H}} {Parsing T Port}
      end
   end

   fun {PrendreLigneN NbeFichier NbeLigne DossierTweet Fichier}
      {Scan {New FichierTexte init(nom: DossierTweet#"/"#{List.nth Fichier NbeFichier})} NbeLigne}
   end

   
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
                A = {List.append Acc [K#V]}
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
            found(V)
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
    
   fun {Prediction Liste Acc}
        case Liste
        of nil then Acc
        [] H|T then
            if {String.toInt {VirtualString.toString H.2.1}} > {String.toInt {VirtualString.toString Acc.2.1}} then   %%% modifiable???
                {Prediction T H}
            elseif {String.toInt {VirtualString.toString H.2.1}} == {String.toInt {VirtualString.toString Acc.2.1}} then
                {Prediction T [{List.append Acc.1 [H.1]} H.2.1]}                                                        %%% verifier que ca fonctionne
            else
                {Prediction T Acc}
            end
        end
   end
   
   fun {GetLastMots Phrase}
        case Phrase of nil then nil
        [] Mot1|Mot2|nil then Mot1|Mot2
        [] H|T then {GetLastMots T}
        end
   end

   %%% Fetch Tweets Folder from CLI Arguments
   %%% See the Makefile for an example of how it is called
   fun {GetSentenceFolder}
      Args = {Application.getArgs record('folder'(single type:string optional:false))}
   in
      Args.'folder'
   end

   %%% Decomnentez moi si besoin
   %proc {ListAllFiles L}
   %   case L of nil then skip
   %   [] H|T then {Browse {String.toAtom H}} {ListAllFiles T}
   %   end
   %end
    
   %%% Procedure principale qui cree la fenetre et appelle les differentes procedures et fonctions
   proc {Main}
      TweetsFolder = {GetSentenceFolder}
   in
      %% Fonction d'exemple qui liste tous les fichiers
      %% contenus dans le dossier passe en Argument.
      %% Inspirez vous en pour lire le contenu des fichiers
      %% se trouvant dans le dossier
      %%% N'appelez PAS cette fonction lors de la phase de
      %%% soumission !!!
      % {ListAllFiles {OS.getDir TweetsFolder}}
       
      local NbThreads InputText OutputText Description Window SeparatedWordsStream SeparatedWordsPort in
	 {Property.put print foo(width:1000 depth:1000)}  % for stdout siz
	 
            % TODO
	 
            % Creation de l interface graphique
	 Description=td(
			title: "Text predictor"
			lr(text(handle:InputText width:50 height:10 background:blue foreground:white wrap:word) button(text:"Predict" width:15 action:Press))
			text(handle:OutputText width:50 height:10 background:black foreground:white glue:w wrap:word)
			action:proc{$}{Application.exit 0} end % quitte le programme quand la fenetre est fermee
			)
	 
            % Creation de la fenetre
	 Window={QTk.build Description}
	 {Window show}
	 
	 {InputText tk(insert 'end' "Loading... Please wait.")}
	 {InputText bind(event:"<Control-s>" action:Press)} % You can also bind events
	 
            % On lance les threads de lecture et de parsing
	 SeparatedWordsPort = {NewPort SeparatedWordsStream}
	 NbThreads = 4
	 {LaunchThreads SeparatedWordsPort NbThreads}
	 
	 {InputText set(1:"")}
      end
   end
    % Appelle la procedure principale
   {Main}
