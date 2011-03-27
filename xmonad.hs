import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Layout.Grid
import XMonad.Layout.IM
import XMonad.Layout.Reflect
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.PerWorkspace
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.Loggers
import XMonad.Prompt
import XMonad.Prompt.Shell
import XMonad.Util.EZConfig (additionalKeys)
import Data.Ratio ((%))
import System.IO
import Control.Monad (liftM2)
import qualified XMonad.StackSet as W
 
-- Constants
devWorkspace = "dev"
webWorkspace = "web"
termWorkspace = "term"
docWorkspace = "doc"
scratchWorkspace = "scratch"
imWorkspace = "IM" 

-- Main
main = do
    statusBarPipe <- spawnPipe "xmobar $HOME/.xmonad/xmobarrc"
    xmonad $ defaultConfig
        { workspaces = [devWorkspace, webWorkspace, termWorkspace, docWorkspace, scratchWorkspace, imWorkspace],          
          manageHook = myManageHooks <+> manageHook defaultConfig,          
          layoutHook = myLayouts,
          logHook = dynamicLogWithPP $ myXmobarPP statusBarPipe,
          borderWidth = 2,
          focusedBorderColor = "#CC2020"
        } `additionalKeys`
        [
          ((mod1Mask,           xK_r), shellPrompt myPromptConfig),
          ((mod1Mask,           xK_a), sendMessage MirrorExpand),
          ((mod1Mask,           xK_z), sendMessage MirrorShrink )         
        ]
        
-- Windows organization
myManageHooks = composeAll
  [
    className =? "Chromium-browser" --> viewShift webWorkspace,
    className =? "Skype" --> viewShift imWorkspace,
    className =? "Pidgin" --> viewShift imWorkspace,
    className =? "Eclipse" --> viewShift devWorkspace,
    manageDocks
  ]
  where viewShift = doF . liftM2 (.) W.greedyView W.shift
        
-- Xmobar Pretty Printer configuration
myXmobarPP pipe = xmobarPP {
  ppCurrent = wrap "<fc=#CC9393>[" "]</fc>",
  ppHidden = wrap "[" "]",
  ppHiddenNoWindows = wrap "[" "]",
  ppSep = "    |    ",
  ppTitle = wrap "<fc=#F0DFAF>" "</fc>",
  ppLayout = wrap "Layout: <fc=#F0DFAF>" "</fc>", --(\s -> ""),
  ppOutput = hPutStrLn pipe
}

-- Layout configuration
myTabbedLayout = tabbed shrinkText defaultTheme {
  fontName = "xft:Ubuntu:pixelsize=11"
}
  
myIMLayout = reflectHoriz $ withIM (0.20) (Role "buddy_list") $ withIM (0.20) (Role "MainWindow") (Grid ||| Full)
 
myLayouts = avoidStruts $ 
            onWorkspace webWorkspace myTabbedLayout $
            onWorkspace imWorkspace myIMLayout $
            standardLayouts
          where 
            standardLayouts = tiled ||| Mirror tiled ||| Full
            tiled = ResizableTall 1 (3/100) (1/2) []
            

-- Dynamic shell prompt configuration
myPromptConfig = defaultXPConfig {
  font = "xft:Ubuntu:pixelsize=11",
  height = 26,
  bgColor = "#3F3F3F",
  fgColor = "#DCDCCC",
  bgHLight = "#CC9393",
  borderColor = "#F0DFAF",
  showCompletionOnTab = True,
  position = Top
}

