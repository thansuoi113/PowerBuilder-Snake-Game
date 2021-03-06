$PBExportHeader$w_snake.srw
forward
global type w_snake from window
end type
type st_score from statictext within w_snake
end type
type dw_1 from datawindow within w_snake
end type
type asnake from datastore within w_snake
end type
end forward

global type w_snake from window
integer width = 2533
integer height = 1408
boolean titlebar = true
string title = "Snake"
string menuname = "m_snake"
boolean controlmenu = true
long backcolor = 67108864
string icon = "AppIcon!"
st_score st_score
dw_1 dw_1
asnake asnake
end type
global w_snake w_snake

type variables
constant	long	dirLeft =1
constant	long	dirRight=2
constant	long	dirUp   =3
constant	long	dirDown =4

keycode			KeyLeft =KeyLeftArrow!
keycode			KeyRight=KeyRightArrow!
keycode			KeyUp   =KeyUpArrow!
keycode			KeyDown =KeyDownArrow!
keycode			KeyPause=KeySpaceBar!

long				snake_len   =20
long				rows        =20
long				cells       =40
long				grow_every  =1
long				apples_eaten=0
long				score       =0
long				direction   =dirRight
boolean			onTimer     =FALSE
boolean			isPaused    =TRUE
boolean			applevisible=FALSE
decimal			atimer      =0.08
nvo_list			keylist
end variables

forward prototypes
public subroutine wf_preparegrid (integer atype)
public subroutine wf_loadsnake (integer atype)
public subroutine wf_insertapple ()
end prototypes

public subroutine wf_preparegrid (integer atype);string	mod_str,colorstr,acell,pencol
long		i,j,ax,title_height,randgen,aw,ah
any		empty[]
ulong		temp


aw    =40
ah    =36

dw_1.DataObject='d_grid'
dw_1.Reset()
dw_1.SetRedraw(FALSE)

//Create grid
ax=0
for i=1 to cells

	colorstr=string(RGB(0,0,0))
	pencol  =string(RGB(255,0,0))
	mod_str+='create rectangle(band=detail x="'+string(ax)+'" y="0" height="'+string(ah)+'" width="'+string(aw)+'" '+'name=cell_'+string(i,'00')+' '+&
	         'visible="1~tIf(long(mid(cells,'+string(i)+',1))=1,1,0)" brush.hatch="6" brush.color="'+colorstr+'" pen.style="2" '+&
				'pen.width="1" pen.color="'+pencol+'"  background.mode="2" background.color="536870912") '

	ax=ax+aw
next

dw_1.Modify(mod_str)
dw_1.Modify('DataWindow.Detail.Height='+string(ah))

for i=1 to rows
	dw_1.InsertRow(0)
	acell=''
	for j=1 to cells
		acell+='0'
	next
	dw_1.SetItem(i,1,acell)
next
dw_1.SetRedraw(TRUE)

dw_1.height=rows*(long(dw_1.Describe('Datawindow.Detail.Height'))+1)
dw_1.width =ax

title_height=this.height - this.Workspaceheight()
this.height=dw_1.y +dw_1.height+title_height -20
this.width =dw_1.width +32

randgen=year(today())+month(today())*day(today())+hour(now())*minute(now())+second(now())+cpu()
randomize(randgen)

wf_loadsnake(atype)
wf_insertapple()
timer(atimer)
onTimer  =FALSE
isPaused =FALSE
direction=dirRight
keylist.of_reset()
score=0
end subroutine

public subroutine wf_loadsnake (integer atype);//Load Snake in to its initial position
string	temp
long		arow,i


asnake.Reset()
for i=snake_len to 1 step -1
	arow  =asnake.InsertRow(0)
	asnake.SetItem(arow,1,i)
	asnake.SetItem(arow,2,1)
next

temp=dw_1.GetItemString(1,1)
temp=Replace(temp,1,snake_len,Fill('1',snake_len))
dw_1.SetItem(1,1,temp)
end subroutine

public subroutine wf_insertapple ();string	temp
long		ax,ay,cell_x

temp='destroy apple'
dw_1.Modify(temp)

begin:
ax=rand(cells)
ay=rand(rows)

//this.Title='x='+string(ax)+' - y='+string(ay)

if ax=0 then ax=1
if ay=0 then ay=1

temp=dw_1.GetItemString(ay,1)
if mid(temp,ax,1)<>'0' then goto begin

temp=Replace(temp,ax,1,'9')
dw_1.SetItem(ay,1,temp)
cell_x=long(dw_1.Describe('cell_'+string(ax,'00')+'.x'))

temp='create text(band=detail alignment="0" text="©" border="0" color="128" x="'+string(cell_x)+'" y="0" height="32" width="37" html.valueishtml="0" '+&
     'name=apple visible="0~tif(getrow()='+string(ay)+',1,0)"  font.face="Small Fonts" font.height="-7" font.weight="400"  font.family="2" font.pitch="2" font.charset="161" background.mode="1" background.color="553648127")'
	  
dw_1.Modify(temp)
end subroutine

event open;wf_preparegrid(0)
f_center_window(this)
dw_1.Post SetFocus()

end event

on w_snake.create
if this.MenuName = "m_snake" then this.MenuID = create m_snake
this.st_score=create st_score
this.dw_1=create dw_1
this.asnake=create asnake
this.Control[]={this.st_score,&
this.dw_1}
end on

on w_snake.destroy
if IsValid(MenuID) then destroy(MenuID)
destroy(this.st_score)
destroy(this.dw_1)
destroy(this.asnake)
end on

event timer;string	temp
long		head_x,head_y,tail_x,tail_y
boolean	grow=FALSE

yield()

//Get last direction change if any
if keylist.of_datacount()>0 then direction=long(keylist.of_get())
if isPaused then return
if onTimer then return
onTimer=TRUE

//Get current head
head_x=asnake.GetItemNumber(1,1)
head_y=asnake.GetItemNumber(1,2)

//According to current direction calculate new head's position
choose case direction
	case dirRight
		head_x ++
		if head_x>cells then head_x=1
	case dirLeft
		head_x --
		if head_x<1 then head_x=cells
	case dirUp
		head_y --
		if head_y<1 then head_y=rows
	case dirDown
		head_y ++
		if head_y>rows then head_y=1
end choose

//Make Sure that new head is not snakes body or obstacle
temp=dw_1.GetItemString(head_y,1)

if mid(temp,head_x,1)='1' then
	MessageBox('Snake','GAME OVER')
	timer(0)
	return
end if

//Check if our snake have eaten the apple!
if mid(temp,head_x,1)='9' then
	wf_insertapple()
	apples_eaten ++
	if apples_eaten=grow_every then
		apples_eaten=0
		grow=TRUE
	end if
	score+=9
	st_score.event ue_refresh()
end if

//Insert New Head
asnake.InsertRow(1)
asnake.SetItem(1,1,head_x)
asnake.SetItem(1,2,head_y)

//Draw New Head
temp=dw_1.GetItemString(head_y,1)
temp=Replace(temp,head_x,1,'1')
dw_1.SetItem(head_y,1,temp)

//Delete Old Tail
if not grow then
	tail_x=asnake.GetItemNumber(asnake.RowCount(),1)
	tail_y=asnake.GetItemNumber(asnake.RowCount(),2)
	temp=dw_1.GetItemString(tail_y,1)
	temp=Replace(temp,tail_x,1,'0')
	dw_1.SetItem(tail_y,1,temp)
	asnake.DeleteRow(asnake.RowCount())
end if

onTimer=FALSE
end event

event resize;st_score.width=this.WorkspaceWidth()
end event

type st_score from statictext within w_snake
event ue_refresh ( )
integer y = 4
integer width = 402
integer height = 68
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 65535
long backcolor = 0
string text = "Score: "
boolean focusrectangle = false
end type

event ue_refresh();this.Text='  Score: '+string(score)
end event

type dw_1 from datawindow within w_snake
event ue_keypressed pbm_dwnkey
integer y = 68
integer width = 2400
integer height = 672
integer taborder = 10
string title = "none"
string dataobject = "d_grid"
boolean border = false
boolean livescroll = true
end type

event ue_keypressed;if key=KeyPause then
	isPaused=not isPaused
end if
if ispaused then return


if key=KeyUp and direction<>dirDown then
	//direction=dirUp
	keylist.of_put(dirUp)
end if

if key=KeyDown and direction<>dirUp then
	//direction=DirDown
	keylist.of_put(dirDown)
end if

if key=KeyLeft and direction<>dirRight then
	//direction=DirLeft
	keylist.of_put(dirLeft)
end if

if key=KeyRight and direction<>dirLeft then
	//direction=dirRight
	keylist.of_put(dirRight)
end if

end event

type asnake from datastore within w_snake descriptor "pb_nvo" = "true" 
string dataobject = "d_snake"
end type

on asnake.create
call super::create
TriggerEvent( this, "constructor" )
end on

on asnake.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

