Lets make a theme!

Im gonna start by getting an empty theme (With the proper directories). It looks like this:

 Theme
     BGAnimations
	 Graphics
	 Scripts
	 Sounds
	 Languages
	 metrics.ini
	 
We will go over these as we use them. But for now, lets jump right into it!
We will start making the TitleMenu (aka Main Menu). Here is the concept art for my idea of a theme (). I basically dont want a main menu. So the first thing I'm gonna do is kill the main menu.
We're going to do this by making a file called "ScreenTitleMenu overlay.lua" in BGAnimations. When Etterna/Stepmania loads a new screen, it loads a bunch of lua files for that screen from the themes BGAnimations. The difference between the files is usually the draw order (Overlay being the uppermost, decorations the middle one and underlay the background).

The first important piece of code we're gonna be using is gonna allow us to manually change screens. This is done with the following code:
```SCREENMAN:GetTopScreen():SetNextScreenName("ScreenName"):StartTransitioningScreen("SM_GoToNextScreen") ```
We can make it into a function so our code will be more readable:
```
function ChangeScreen(screen)
	SCREENMAN:GetTopScreen():SetNextScreenName(screen):StartTransitioningScreen("SM_GoToNextScreen") 
end```
This function is probably gonna be used in many different files. Therefore, we dont want to define it more than once. We want to make it's scope (Where we can use it) our whole theme. To do this we will make a /Scripts/ file. The files in this folder are all loaded when the game starts, and everything in them is global and accesible/usable from anywhere in the theme (With the exception of other /Scripts/ files. The game loads these files in alphabetical order, so we cant use something defined in a file that comes after the one we're coding in alphabetical order).
We will call it "09 ScreenUtility.lua". Note the "09" prefix. This is the usual convention to force a specific load order for /Scripts/ files. Since this file wont depend on other scripts, we can use a high number prefix (Meaning it will be loaded last or close to last).

So, going back to BGAnimations, the code in "ScreenTitleMenu overlay.lua" is going to be run when we reach the TitleMenu. Then we can think of doing this:
```
ChangeScreen("ScreenSelectProfile")```
But the reality is that, even if the code is run when we reach it, usually the most we can do directly in the file is just change the values of global variables. But dont despair! The way theming works each BGA file returns an Actor, which will later be loaded in the screen. But, what is an Actor you ask? If you're familiar with Object Oriented Programming you can think of an Actor as an object (It's actually a lua table with some special things). What matters is that there are different kinds of Actors (We will learn about them bit by bit with examples), each having its own functionality.
The basic Actor is the container Actor, called ActorFrame. Almosts all it does is own other Actors. Usually all BGA files return an ActorFrame. Here is how we define an actor frame and return it (This would be "ScreenTitleMenu overlay.lua")
```local t = Def.ActorFrame{}
return t```
But this wont do anything! How do we make the ActorFrame *do* stuff? For theming (And all smlua) theres things called Commands. They're like functions each actor may or may not have, that if found will be called on certain events. The most basic but still incredibly useful is the InitCommand. All Actors have this command, and I will mention now that not all Actors have the same commands. So, now we're going to make the ActorFrame change the screen as soon as TitleMenu is loaded.
```
local t = Def.ActorFrame{
	InitCommand = function(self)
		changeScreen("ScreenSelectProfile")
	end
}
return t
```
Good, we've finally got rid of TitleMenu forever. But this solution is kinda hacky isnt it? We're making the game go into the screen and then inmediately leaving. Lets try to prevent the game from ever reaching it!
In theming, theres a special global table called Branches. This defines under which conditions each screen goes to another screen when they're left. It does this by storing functions which are called on certain events, and these functions return a string, the name of the next screen (And since they're functions we can use ifs and all kinds of conditionals/code)
We're gonna make a file in /Scripts/ (Since branches are global) called "02 Branches.lua" (02 out of convention)