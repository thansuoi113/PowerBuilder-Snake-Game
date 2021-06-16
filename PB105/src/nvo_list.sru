$PBExportHeader$nvo_list.sru
forward
global type nvo_list from nonvisualobject
end type
end forward

global type nvo_list from nonvisualobject autoinstantiate
end type

type variables
Private:

any		data[]

end variables

forward prototypes
public function long of_put (any adatum)
public function any of_get ()
public subroutine of_reset ()
public function long of_datacount ()
end prototypes

public function long of_put (any adatum);data[UpperBound(data) +1]=adatum
return UpperBound(data)
end function

public function any of_get ();any		adatum,empty[],temp[]
long		i

setnull(adatum)
if UpperBound(data)>0 then
	adatum=data[1]
	for i=2 to Upperbound(data)
		temp[i -1]=data[i]
	next
	data=empty
	data=temp
end if

return adatum
end function

public subroutine of_reset ();any	empty[]

data=empty
end subroutine

public function long of_datacount ();return UpperBound(data)
end function

on nvo_list.create
call super::create
TriggerEvent( this, "constructor" )
end on

on nvo_list.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

