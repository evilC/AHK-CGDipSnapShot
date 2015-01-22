AHK-CGDipSnapShot
=================

An AHK library for working with snapshots of a portion of the screen (compare, easy conversion etc)

###What does it do?
It adds a layer on  top of the GDI+ ("Gdip") library that introduces the concept of *Snapshots*.

A Snapshot is a screen grab of a box from the screen, which can then be examined using a command syntactically similar to AHK's `PixelGetColor` command. Pixel checks can be done using coordinates relative to the **Screen** or to the **Snapshot**.

The advantage of this technique is that you can perform multiple checks on an area of the screen, *without the worry of the screen changing between one check and another*.  

You can also take multiple Snapshots at any given moment(s), easily save Shapshots to disk, and also a mechanism is provided to easiliy display Snapshots on the screen.

Example script included.

###Using this library in your projects
####Setup
#####Easy Method
1. Clone this project using GitHub for Windows.
You can click here
On the main page for this project on GitHub, click **Clone in Desktop** on the right edge of the page.  
Or you can try [this link](github-windows://openRepo/https://github.com/evilC/AHK-CGDipSnapShot).  
This will clone this Project ("Repository") onto your computer.  
If there are updates to this Library, you can then Synch with GitHub to get the latest version. 
1. Run `Setup.exe` from the repoistory you just downloaded.  
This will check you are all set up to use the library and configure AutoHotkey so you can easily include the library in any script in any folder on your computer.
2. Check the *DEVELOPER NOTES* section to see if there are any special instructions, then click *Install*.
3. You are now set up and can use this library by putting the following line at the start of your script:  
`#include <CGDipSnapshot>`

#####Manual Method
If you know what you are doing, or are paranoid, or both, you can just obtain the files and `#include` as normal. The Setup app simply makes it easy for people who don't really know what they are doing to get up and running with this library (For example, check for out-of-date AHK version from Autohotkey.com, instead of an up-to-date version from http://ahkscript.org)

####Usage
Help on usage should be obtainable from the following sources (Best to Worst):

* Project [Wiki](https://github.com/evilC/AHK-CGDipSnapShot/wiki)
* Example scripts.  
These usually illustrate basic set-up and usage.
* Library Source.  
May need to check this to see full list of features.

