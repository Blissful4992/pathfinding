This work is licensed under a [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by-nc-nd/4.0/)
[View Full LICENSE Text](https://github.com/Blissful4992/pathfinding/blob/main/LICENSE)

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
<br/>
![](https://github.com/Blissful4992/pathfinding/raw/main/explanation.png)
