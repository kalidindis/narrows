# NARROWS

NARROWS is an online storytelling system. The name stands for
NARRation On Web System. The easiest way to explain it is to
imagine an online [gamebook](https://en.wikipedia.org/wiki/Gamebook)
with the following differences:

1. Instead of having a single reader, there are as many readers as
   protagonists in the story (it could be one, but also four or five).
1. Instead of having to choose between two or three preset choices
   after each "chapter", readers can _write_ in a textbox whatever
   their characters do.
1. Instead of the narrator writing the whole story with all possible
   branches upfront, then give it to the readers; the narrator writes
   only one chapter at a time and waits for the readers to submit the
   "actions" for their characters. Based on those actions, the
   narrator writes the next chapter.

You can also think of it as a way of running ruleless, diceless RPGs
online (which is indeed the reason why I wrote it in the first
place).


# Installation

NARROWS is a web application with a backend. As such, it needs a
server connected to the internet to be used. To install you need to
run the following steps:

1. Clone the code somewhere.
1. Make sure you have Node.js (at least version 4) and NPM (at least
   version 4).
1. Run `npm install`
1. Run `npm install -g elm@0.18`
1. Run `elm-package install`
1. Run `npm run buildfe` and `npm run buildbe`
1. Install MySQL, create a new user and an empty MySQL database. Make
   sure the new user has all privileges to that database.
1. Copy `config/default.js` to `config/local-production.js` and modify
   any values you need.
1. Run `db-migrate up`
1. Run `NODE_ENV=production node build/index.js`

If all this works you will have to find a way to keep the server
running, eg. [supervisor](http://supervisord.org/).

## Updating the code

Every time you update the code you will have to install any new
dependencies with:

    npm install

And run any new migrations with:

    db-migrate up

Then you will have to recompile the frontend and backend code with:

    npm run buildfe && npm run buildbe


# Credits

* Speaker/mute icons made by
  [Madebyoliver](http://www.flaticon.com/authors/madebyoliver), from
  [Flaticon](http://www.flaticon.com). They are licensed under
  Creative Commons BY 3.0.
* Trash icon by [Freepik](http://www.flaticon.com/authors/freepik),
  from [Flaticon](http://www.flaticon.com). Licensed under Creative
  Commons BY 3.0.
* Add/plus icon, message icon and user icon by
  [Lucy G](http://www.flaticon.com/authors/lucy-g), from
  [Flaticon](http://www.flaticon.com). Licensed under Creative Commons
  BY 3.0.
* RSS icon by [Dave Gandy](http://www.flaticon.com/authors/dave-gandy)
  from [Flaticon](http://www.flaticon.com). Licensed under Creative
  Commons BY 3.0.
* Vintage divider by
  [Web Design Hot](http://www.webdesignhot.com/free-vector-%20graphics/vector-set-of-vintage-design-divider-elements/). Licensed
  under Creative Commons BY 3.0.
