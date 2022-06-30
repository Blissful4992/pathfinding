This work is licensed under a [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by-nc-nd/4.0/)<br/>
[View Full LICENSE Text](https://github.com/Blissful4992/pathfinding/blob/main/LICENSE)<br/>
<br/>
Link to a place where you can test this: [link](https://www.roblox.com/games/10042997623/pathfinding)<br/>
<br/>
![](https://mirrors.creativecommons.org/presskit/buttons/88x31/svg/by-nc-nd.svg)
### Mapping
* First we recursively find all intersect points from the top of the world to the bottom (red)
These points will be the tops of all parts

* We do the same but starting from the bottom to the top (green)
These points will be the bottoms of all parts

* The top of the world is point [0] for the bottom intersect group

Mathematically we then have the relations between points of both groups:<br/>
`Bottom of each hole (red): top[i]`<br/>
`Top of each hole (green): bottom[i-1]`<br/>
<br/>
To get the size of the hole we just do `top[i].y - bottom[i-1].y` and we check if its taller than our agent height.<br/>
If the size is 0, or it is negative, then it is not a hole.<br/>
<br/>
This method can be done on thousands, even millions of points and it will generate those that are traversable by your agent.<br/>
With these points we then snap them to a grid of a fixed separation, after this, it's very easy to get the points next to a certain point (if you want to do pathfinding).<br/>
<br/>
This is an example of a terrain (all 3 are identical, they are split for ease of understanding).<br/>
<br/>
![](https://i.imgur.com/XNVtIcf.png)<br/>
<br/>
Here's an example of what you can get:<br/>
<br/>
![](https://cdn.discordapp.com/attachments/743547673205932042/992029703756075008/unknown.png)<br/>
<br/>
Here's an example of what you can expect in an actual game:<br/>
![](https://cdn.discordapp.com/attachments/743547673205932042/992056535993831474/unknown.png)<br/>

<br/>
![]()<br/>
