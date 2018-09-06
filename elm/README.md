# Plato (Frontend)

Plato aims to become the go-to Urbit solution
for fast prototyping, code sharing, showcasing and education.

Planned features:
- Nock/Hoon modes
- Integration with Clay and Ford

Plato does not try to be a full featured editor such as Atom,
but instead is meant as a quick-and-dirty Hoon sandbox.

The project makes use of `elm-urbit` connector - 
an Elm library which makes it easy to build Urbit applications 
in Elm. 

# Install

Get plato up and running on your urbit in seconds.
Head to http://www.urbitetorbi.org/plato/install
for installation guide. 

# Running locally

Make sure you have necesarry tools: elm binary, yarn, webpack.
After cloning the repository run
1. yarn install
3. yarn dev

A dev server will fire up on `http://localhost:3000`.
The Urbit API requests are proxied to `http://localhost:8080`
so make sure your Urbit occupies this port, or you will have to change 
it in `webpack.config.js`.
