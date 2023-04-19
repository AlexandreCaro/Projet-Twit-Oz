functor
import
    Open
export
    fichierTexte:FichierTexte
    insert:Insert
    scanLine:ScanLine
    scan:Scan
    expand:Expand


define  
    fun {Insert N Is}
       if N>0 then {Insert N-1 & |Is} else Is end 
    end 
    fun {ScanLine Is Tab N}
       case Is of nil then nil
       [] I|Ir then 
          case I  
          of &\t then M=Tab-(N mod Tab) in {Insert M {ScanLine Ir Tab M+N}}
          [] &\b then I|{ScanLine Ir Tab {Max 0 N-1}}
          else I|{ScanLine Ir Tab N+1}
          end 
       end 
    end 
    proc {Scan Tab IF OF}
       Is={IF getS($)}  
    in 
       if Is==false then  
          {IF close} {OF close}
       else 
          {OF putS({ScanLine Is Tab 0})}
          {Scan Tab IF OF}
       end 
    end 
    class TextFile  
       from Open.file Open.text  
    end 
in 
    proc {Expand Tab IN ON}
       {Scan Tab  
        {New TextFile init(name:IN)}
        {New TextFile init(name:  ON  
                           flags: [write create truncate])}}
    end 


    class FichierTexte
        from Open.file Open.text
    end

end


