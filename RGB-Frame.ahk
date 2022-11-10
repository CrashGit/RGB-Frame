; you only need to change these variables, everything else should auto-calculate based on these values
frame_size              := 3                        ; this is the size of the frame you want around the screen
breathe_in_increment    := 5                        ; amount to increase opacity per breathe_in_speed interval, a smaller number can result in a smoother fade
breathe_out_decrement   := 3                        ; amount to decrease opacity per breathe_out_speed interval, a smaller number can result in a smoother fade
breathe_in_speed        := 40                       ; time it takes to update the opacity
breathe_out_speed       := 45                       ; time it takes to update the transparency
breathe_in_to_breathe_out_transition_pause := -1000 ; when the color reaches full opacity, this is the delay before it increases transparency again
breathe_out_to_breathe_in_transition_pause := -300  ; when the frame is no longer visible, this is the delay before it increases opacity again


; you can add/remove/change these colors to whatever you want
frame_rgb := ['cff0000', 'cff7f00', 'cffff00', 'c00bc3f', 'c0068ff', 'c7a00e5', 'cd300c9']


color_resume := frame_rgb[frame_rgb.Length] ; remembers last color before toggling off
frame_is_toggled_off := false               ; tracks state of toggled frame visibility


CreateFrame()   ; initialize frame gui

F1::    ; toggle on/off when it may be distracting like watching full-screen videos
{
    global frame_is_toggled_off := !frame_is_toggled_off

    if frame_is_toggled_off = false
        CreateFrame()
}

; -------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------
CreateFrame()
{
    ; Create an RGB frame border around the screen
    global Frame := Gui('+AlwaysOnTop -SysMenu +ToolWindow -Caption -Border')
    Frame.BackColor := color_resume      ; starting color

    Frame.Show('x0 y0 w' A_ScreenWidth ' h' A_ScreenHeight  ' NoActivate')  
    WinSetTransparent(0, Frame)         ; start invisible/off
    WinSetExStyle('+0x20', Frame)       ; allows you to click through the frame

    height_offset := A_ScreenHeight - frame_size
    width_offset := A_ScreenWidth - frame_size
    WinSetRegion('0-0 ' A_ScreenWidth '-0 ' A_ScreenWidth '-' A_ScreenHeight ' 0-' A_ScreenHeight ' 0-0 ' frame_size '-' frame_size ' ' width_offset '-' frame_size ' ' width_offset '-' height_offset ' ' frame_size '-' height_offset ' ' frame_size '-' frame_size, Frame) ; creates the frame

    SetTimer(BreatheIn, breathe_in_speed)   ; begin rgb color change
}
; -------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------

BreatheIn()
{
    if frame_is_toggled_off {
        Frame_Destroy()
        return
    }

    transparency := WinGetTransparent(Frame) + breathe_in_increment
    
    try WinSetTransparent(transparency, Frame)
    catch {
        WinSetTransparent(255, Frame)
    }

    if transparency >= 255 {
        SetTimer(BreatheIn, 0)
        SetTimer(() => SetTimer(BreatheOut, breathe_out_speed), breathe_in_to_breathe_out_transition_pause)  ; pause before breathing out
    }
}

BreatheOut()
{
    if frame_is_toggled_off {
        Frame_Destroy()
        return
    }

    transparency := WinGetTransparent(Frame) - breathe_out_decrement

    try WinSetTransparent(transparency, Frame)
    catch {
        WinSetTransparent(0, Frame)
    }

    if transparency <= 0
    {
        SetTimer(BreatheOut, 0)
        static colorIndex := frame_rgb.Length   ; start at the last color of the array

        Frame.BackColor := frame_rgb[CheckColorIndexIsValid(colorIndex+1)]

        CheckColorIndexIsValid(color)
        {
            if color > frame_rgb.Length {  
                colorIndex := 1
                color := colorIndex
            } 
            else {
                colorIndex++
            }
            global color_resume := frame_rgb[color]
            return color
        }
        SetTimer(() => SetTimer(BreatheIn, breathe_in_speed), breathe_out_to_breathe_in_transition_pause) ; pause before breathing in
    }
}

Frame_Destroy()
{
    global
    if IsSet(Frame) {
        SetTimer(BreatheIn, 0)
        SetTimer(BreatheOut, 0)
        SetTimer(() => SetTimer(BreatheOut, 0), 0)
        SetTimer(() => SetTimer(BreatheIn, 0), 0)
        Frame.Destroy()
        Frame := unset
    }
}