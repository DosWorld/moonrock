
code segment word public
assume cs:code
public end_of_code

  end_of_code:

; Defines end of CODE segment

code ends


data segment word public
assume cs:data
public $StartOfDynamic

  $StartOfDynamic:

; Defines start of dynamic memory manager in DATA segment

data ends
end

