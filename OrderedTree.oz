
% LINFO1104 Lecture 2
% Feb. 14, 2023
% Ordered binary tree operations

declare
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

declare
fun {Insert K W T}
      case T
      of leaf then tree(key:K value:W leaf leaf)
      [] tree(key:Y value:V T1 T2) andthen K==Y then % Replace old value
            tree(key:K value:W T1 T2)
      [] tree(key:Y value:V T1 T2) andthen K<Y then
            tree(key:Y value:V {Insert K    W T1} T2)
      [] tree(key:Y value:V T1 T2) andthen K>Y then
            tree(key:Y value:V T1 {Insert K W T2})
      end
end

% Correct version of delete
% Uses helper function RemoveSmallest
declare
fun {RemoveSmallest T}
      case T
      of leaf then none
      [] tree(key:X value:V T1 T2) then
            case {RemoveSmallest T1}
            of none then triple(T2 X V)
            [] triple(Tp Xp Vp) then
	 triple(tree(key:X value:V Tp T2) Xp Vp)
            end
      end
end

declare
fun {Delete K    T}
      case T
      of leaf then leaf
      [] tree(key:Y value:W T1 T2) andthen K==Y then
            case {RemoveSmallest T2} 
            of none then T1
            [] triple(Tp Yp Vp)    then
	 tree(key:Yp value:Vp T1 Tp)
            end
      [] tree(key:Y value:W T1 T2) andthen K<Y then
            tree(key:Y value:W {Delete K T1} T2)
      [] tree(key:Y value:W T1 T2) andthen K>Y then
            tree(key:Y value:W T1 {Delete K T2})
      end
end

% Example tree
declare
T=tree(key:horse value:cheval
              tree(key:dog value:chien
	        tree(key:cat value:chat leaf leaf)
	        tree(key:elephant value:elephant leaf leaf))
              tree(key:mouse value:souris
	        tree(key:monkey value:singe leaf leaf)
	        tree(key:tiger value:tigre leaf leaf)))