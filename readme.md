Vlipco's Website
===============

# How to use this repo

You need node v.0.10 or older, then install the following _global dependencies_ with `npm install -g <pkg-name>`:

* broccoli-cli
* bower

After you have the global deps, you can install this repo's dependencies with:

* `npm install`
* `bower install`

You should be ready to serve the site for development with `broccoli serve  --host 0.0.0.0`. This would serve the site on `localhost:4200` and reload as you change files in the source folder. The host option in the serve command is optional but allows you to load the site from other devices on your same network by using your IP, for instance to check mobile versions on real smartphones.

If you want to build the whole site into a local folder you can do `broccoli build dist` and that would create the dist folder with all the required files. You can then go into this folder in your terminal and run `python -m SimpleHTTPServer` to test the standalone compiled site and see it has all files required. The python command starts a server that listen on `localhost:8000`.

# Understanding the file structure

The whole website is build on a strong decoupling of HTML markup and textual copy. For this the site has the following components that come together in a bundle of assets, html, css and javascript:

* Reusable blocks of HTML markup (written in emblem).
* Layout where all blocks of a page come toether to form a single HTML file.
* A global application javascript file (in coffeescript).
* A global application sass stylesheets.
* Vendored binaries and css/js.

The order in which the whole site is build is as follows:

* Every `.page` file in `source/pages` is read. This a YAML file that has a sections key equaling to an array of objects. Each of those object has a block attribute and constitutes the data of that block.
* The data of every block is used to compile the corresponding block emblem source. This means that the section data is the template's rendering context of the emblem markup.
* The result HTML is then stored and stacked in order once all blocks have compiled. These are the page contents.
* The page layout (as specified in the .page file) is loaded and the context to compile that layout is all the yaml values _excluding the sections content_. The template is then compiled and the result is the final HTML of the page. It's written to disk according to the path you have in the `slug` top property in the yaml file.
* Afterwards app.sass is compiled, anything you want to include you need to put using the sass `@import` directive. Ideally you should keep a sass file per block and avoid global styling.
* Then app.js is created. This is the result of `app.coffee` being concatenated with all other `js` and `coffee` files in the `vendor` and `source/global` directories. There's no guaranteed order, so any code that you have need to handle module loading (e.g. dependency injection) in some way or run after the document is ready. This is just a warning for hardcore JS cases but should be a rare concern since this is a repo for informational websites rather than frontend apps.
* Finally all non JS/CSS/HTML/SASS/SCSS/COFFEE files under `source/assets` and `source/vendor` will be copied to the final website files, this is how images and webfonts endup being included. Keep this in mind to avoid leaking files to you final build that may be dev only files. You can make a `broccoli build dist` to see all the files that endup in a build and confirm only the desired files end there.

# How to create pages and blocks

Take a look in `source/pages` and you'll see how a page is structured. Simply note that every section has a block property and that the block must exist in `source/blocks` as an emblem file. For every final website url you create a `.page` file and set the final path with the `slug` property. To handle multiple languages, simply create namespace slugs, eg: `/en/about`, `/en/contact`. Note that becuase of the slug property there's no relationship between file structure and the website's map (for now).

Creating new blocks should be rare as the idea of this website's code structure is exactly to allow you to write copy and structure pages using existing carefuly tuned blocks that are responsive out of the box. However, if you find the need, here's how to create blocks.

To create new blocks you create the markup as an emblem file, then you can add optional sass for your block in `source/global/blocks` as a sass partial. If you add the sass partial you must import it in `source/global/blocks/_blocks.sass`. Block are handlebars templates since they're emblem.js documents, you can use this to customize the markup rendering based on the context. You can even create sophisticated handlerbars helpers by defining the functions in `lib/blocksite-compiler/lib/handlebars.coffee`.

# Known bugs

* In some cases the server will fail future compilation if you removed or added a new file. This can happen with new pages or when deleting block files. I don't know yet the exact dynamics of the error, just a simple restart of the broccoli server may be needed when adding/deleting some files.

