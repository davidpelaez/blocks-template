Blocks template
===============

# Key points for the busy person

This is a stripped down version of the original site I built this tool for. I think building informational web (landing pages for products or organizations) is a very customized process and every page has to be appealing and full of contrast and interest to tell a compelling story. This makes such a thing slow. If you want a Dribbble quality site you have to work very hard for it and reusability is not great.

This repo provides an example of a block driven page design. You don't think about the page as in premade wordpress templates, instead you compose your page according to the pieces of information. You can reuse existing blocks and customize them. You define variation points per block, e.g: title, wether css classes can be customized, copy, buttons, etc. Your block is filled like a form, you stack them and create a page.

As a prove of concept this is a static site generator with broccoli but this could evolve into a full website builder with UI enabling maximum reusability and design control while allowing content changes with clear boundaries. We could create shareable blocks, structure boundaries between dependencies and convert blocks to react components that could be used for rich editing experiences in a UI and also as isomorphic components used on the server side to render the final version of a site.

The key point to take here is that I don't know of any website builder with full design control that is open source and doesn't consider the page the unit of operation but instead each block or section within it. If I have to make a comparisson to something existing I'd say http://designmodo.com/generator/ is pretty close but strictly oriented to DesignModo startup package. The same arguments that react presents to explain markup, js and styling coupling should apply to website builders. React itself is handy as a key part of the UI. Also block isolation means more attention to detail, faster coding and even a simpler tools for new coders. I have tested this system myself with a person learning HTML and CSS from scratch and it's very easy to grasp and lets the user focus on designing/coding even without much experience. With isolation comes new concepts to explore like [local CSS](https://medium.com/seek-ui-engineering/the-end-of-global-css-90d2a4a06284), regression testing in styling and [post-css](https://github.com/postcss/postcss) mini frameworks. This is an opportunity to apply these concepts in real cases and see how to start to become part of improved best practices to handle information sites.

This system can help create a high quality website that is fully customized but has the cost and time reduction of reusing well known information archetypes expressed a blocks (a head, a horizontal quote, a modal window, etc.).

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

# How to use this repo

Given the short time to apply for Stripe's open source retreat, this is the simplest version of the code I had private and without release. It's now open source and I think the most important part of this readme is to communicate the function and let you browse the source and get the alternative structure that I suggest expressed as a static site generator. However, if you must run it, it works even though it currently doesn't yield the most beatiful site!

You need node v.0.10 or older, then install the following _global dependencies_ with `npm install -g <pkg-name>`:

* broccoli-cli
* bower

After you have the global deps, you can install this repo's dependencies with:

* `npm install`
* `bower install`

You should be ready to serve the site for development with `broccoli serve  --host 0.0.0.0`. This would serve the site on `localhost:4200` and reload as you change files in the source folder. The host option in the serve command is optional but allows you to load the site from other devices on your same network by using your IP, for instance to check mobile versions on real smartphones.

If you want to build the whole site into a local folder you can do `broccoli build dist` and that would create the dist folder with all the required files. You can then go into this folder in your terminal and run `python -m SimpleHTTPServer` to test the standalone compiled site and see it has all files required. The python command starts a server that listen on `localhost:8000`.

# Known bugs

* In some cases the server will fail future compilation if you removed or added a new file. This can happen with new pages or when deleting block files. I don't know yet the exact dynamics of the error, just a simple restart of the broccoli server may be needed when adding/deleting some files.

