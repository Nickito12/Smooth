I'm gonna try making a theme from scratch (I might eventually copy things from other themes, but i want to start from scratch), and make something like a step by step guide/tutorial/commentary/explanation on it while i do so.

### Genesis

Im gonna start by getting an empty theme (With the proper directories). It looks like this (Empty files/directories):
```
	Theme
		BGAnimations
		Graphics
		Scripts
		Sounds
		Languages
		metrics.ini
```
We will go over these as we use them. But for now, lets jump right into it!
We will start making the TitleMenu (aka Main Menu). Here is the concept art for my idea of a theme (). I basically dont want a main menu. So the first thing I'm gonna do is kill the main menu.
We're going to do this by making a file called "ScreenTitleMenu overlay.lua" in BGAnimations. When Etterna/Stepmania loads a new screen, it loads a bunch of lua files for that screen from the themes BGAnimations. The difference between the files is usually the draw order (Overlay being the uppermost, decorations the middle one and underlay the background).

The first important piece of code we're gonna be using is gonna allow us to manually change screens. This is done with the following code:
```
SCREENMAN:GetTopScreen():SetNextScreenName("ScreenName"):StartTransitioningScreen("SM_GoToNextScreen") 
```
We can make it into a function so our code will be more readable:
```
function ChangeScreen(screen)
	SCREENMAN:GetTopScreen():SetNextScreenName(screen):StartTransitioningScreen("SM_GoToNextScreen") 
end
```
This function is probably gonna be used in many different files. Therefore, we dont want to define it more than once. We want to make it's scope (Where we can use it, the "area" or places where the lua interpreter knows/recognizes the identifier/name (ChangeScreen in this case) of our function) our whole theme. To do this we will make a /Scripts/ file. The files in this folder (Scripts) are all loaded when the game starts, and everything in them is global and accesible/usable from anywhere in the theme (With the exception of other /Scripts/ files. The game loads these files in alphabetical order, so we cant use something defined in a file that comes after the one we're coding in alphabetical order). Please note that any lua errors encountered in Scripts will be in the logs file (Etterna/Logs/log.txt) and they will not appear in the ingame debug console.
We will call it "09 ScreenUtility.lua". Note the "09" prefix. Prepending (Adding to the beginning) a number is the usual convention to force a specific load order for /Scripts/ files. Since this file wont depend on other scripts, we can use a high number prefix (Meaning it will be loaded last or close to last).

So, going back to BGAnimations, the code in "ScreenTitleMenu overlay.lua" is going to be run when we reach the TitleMenu. So we can think of doing this:
```
ChangeScreen("ScreenSelectProfile")
```
But the reality is that, even if the code is ran when TitleMenu starts, usually the most we can do directly in the file is just change the values of global variables. In this case our little function will do "SCREENMAN:GetTopScreen" and encounter some kind of error. But dont despair! The way theming works each BGA (BGAnimations) file returns an Actor, which will later be loaded in the screen. But, what is an Actor you ask? If you're familiar with Object Oriented Programming (OOP) you can think of an Actor as an object (It's actually a lua table with some special things). What matters is that there are different kinds of Actors (We will learn about them bit by bit with examples), and each has its own functionality.
The basic Actor is the container Actor, called ActorFrame. Almosts all it does is "own" other Actors. Usually all BGA files return an ActorFrame. Here is how we define an actor frame and return it (This would be "ScreenTitleMenu overlay.lua")
```local t = Def.ActorFrame{}
return t```
But this wont do anything! How do we make the ActorFrame *do* stuff? For theming (And all smlua) theres things called Commands. They're like functions each actor may or may not have, that if found will be called on certain events (This kind of function is often called a *hook*, because its a function that is hooked to a certain event). The most basic but still incredibly useful is the InitCommand. All Actors have this command, and I will mention now that not all Actors have the same commands. So, now we're going to make the ActorFrame change the screen as soon as the TitleMenu screen is loaded.
```
local t = Def.ActorFrame{
	InitCommand = function(self)
		changeScreen("ScreenSelectProfile")
	end
}
return t
```
Good, we've finally gotten rid of TitleMenu forever. But this solution is kinda hacky isnt it? We're making the game go into the screen and then inmediately leaving. Lets try to prevent the game from ever reaching it!
In themes, theres a file called metrics.ini . This file has "sections" and "variables". All metrics variables are inside a section. There "variables" usually have a string or number, but they can also contain functions. You could think of metrics as the "preferences" of your theme. The Etterna Core (Which is in the C++ programming language) reads the metrics file and uses the values in it in a lot of different places. Usually its used for things like managing objects that C++ takes care of (Most/All of these can be replaced with lua equivalents. A good example is the Music Wheel. We'll look at this later), adjusting their position and various options/properties. It also takes care of what i call "Screen Branching". By that i mean the screen/s that each screen goes to. The following is what we're gonna write in our metrics file to change the first screen:
```
[Common]
# First screen that pops up when you start the game. ScreenInit in particular
# shows the theme information before going to the title screen.
InitialScreen="ScreenSelectProfile"
```
It's pretty straight forward. To see what metrics exist you can usually look at fallback's metrics. Theres also special global table called Branches thats related to "Screen Branching". This defines under which conditions each screen goes to another screen when they're left. But, didnt metrics do this you ask? Yes, it did. In fact, all thats happening is that fallback's metrics calls global functions from the Branches table to define some of its "variables". This is a way to avoid metrics and let themers simply define their "Screen Branching" in a /Scripts/ file that overwrites some of the values in said table (Branches) (Sadly theres no branch as of this writing for InitialScreen).

### Main Menu

Now its time to make our main menu. By that i mean making the menu bar thats gonna be at the top of the screen on almost all of this themes screens. Since its gonna be used in many screens, I'm gonna make it a separate file ("\_mainmenu"). Lets first make a "SelectProfile overlay.lua" file that uses the main menu file:
```
local t = {}
t[#t+1] = LoadActor("_mainmenu")
return t
```
LoadActor loads an actor from a lua file (There are other ways to use other files, but we're not gonna go into them). If you ever want to load an actor in a folder that outside the current one, you can use ".." (Ex: "../\_mainmenu"). Now we'll make our main menu. It will be, in essence, a series of clickable buttons which will each have a text, something they will do when clicked (Probably just change the screen) and a condition to be clickable (Like, having a profile selected to go to SelectMusic) that will span the entire width of the screen and, ideally, be retractable. Lets start making our "items":
```function ChangeScreenFunction(screen)
	return function() ChangeScreen(screen) end
end
function IsProfileSelected()
	return (PROFILEMAN:GetProfile(PLAYER_1) and PROFILEMAN:GetProfile(PLAYER_1):GetDisplayName()~="")
end
local items = {
	{name="Play", 
		onClick=ChangeScreenFunction("ScreenSelectMusic"),
		condition=IsProfileSelected
	},
	{name="Profile", 
		onClick=ChangeScreenFunction("ScreenSelectProfile")
	},
	{name="Multiplayer", 
		onClick = function()
			
		end, 
		condition = function()
			return false
		end
	},
	{name="Online Profile", 
		onClick = function()
		
		end, 
		condition = function()
			return false
		end
	},
	{name="Downloads", 
		onClick = function()
		
		end, 
		condition = function()
			return false
		end
	},
	{name="Options", 
		onClick=ChangeScreenFunction("ScreenOptions"),
	},
	{name="Exit", 
		onClick=ChangeScreenFunction("ScreenExit"),
	},
}
```
Each "item" has a name (The button text), an onClick function that does stuff and a condition function that returns a boolean. This is just a first iteration of what these items will be. Next we're gonna add MessageCommands for clicks. Since most screens in this theme will include this main menu file, adding the click commands here will make them available in most screens.
```
local function input(event)
	if event.type ~= "InputEventType_Release" then
		if event.DeviceInput.button == "DeviceButton_left mouse button" then
			MESSAGEMAN:Broadcast("LeftClick")
		elseif event.DeviceInput.button == "DeviceButton_right mouse button" then
			MESSAGEMAN:Broadcast("RightClick")
		end
	end
	return false
end
local t = Def.ActorFrame {
	OnCommand=function(self) 
		SCREENMAN:GetTopScreen():AddInputCallback(input)
	end,
}
```
