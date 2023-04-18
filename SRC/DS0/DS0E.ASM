
_text segment para public 'code'
assume cs:_text
public end_of_code

  end_of_code:

; Defines end of _TEXT segment

_text ends


_data segment para public 'data'
assume cs:_data
public $StartOfDynamic

  $StartOfDynamic:

; Defines start of dynamic memory manager in _DATA segment

_data ends
end

