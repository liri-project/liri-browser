# Material Browser

[![Join the chat at https://gitter.im/tim-sueberkrueb/material-browser](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/tim-sueberkrueb/material-browser?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
A minimalistic material design web browser written for Papyros (https://github.com/papyros/)

### Features
#### Awesome
* [x] Support for custom theme color (meta tag "theme-color")

#### Standard
* [x] Bookmarks
* [x] Favicons
* [x] Download
* [x] Fullscreen
* [x] Search in website
* [ ] Browser history
* [ ] Browser settings

... work in progress!

## Screenshots
![Screenshot](/screenshot_02.png)
![Screenshot](/screenshot_03.png)

## Installation

### Dependencies
* Qt 5.5 and QtWebEngine 1.1
* qml-material (https://github.com/papyros/qml-material)
* qml-extras (https://github.com/papyros/qml-extras)

### Instructions for Ubuntu 15.04
* Install Qt 5.5 (https://www.qt.io)
* Install qml-material
  * git clone https://github.com/papyros/qml-material.git
  * cd qml-material
  * qmake
  * make
  * make check # Optional, make sure everything is working correctly
  * sudo make install
* Install qml-extras
  * git clone https://github.com/papyros/qml-extras.git
  * cd qml-extras
  * qmake
  * make
  * make check # Optional, make sure everything is working correctly
  * sudo make install

### Build and Run
  * git clone https://github.com/tim-sueberkrueb/material-browser.git
  * cd material-browser
  * qmake
  * make
  * run material-browser executable

## Copyright and License
This application is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

See LICENSE for more information.

(C) Copyright by Tim Süberkrüb, 2015
