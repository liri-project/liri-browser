# Material Browser
A minimalistic material design web browser written for Papyros (https://github.com/papyros/)

### Features
#### Awesome
* [x] Support for custom theme color (meta tag "theme-color")

#### Standard
* [x] Favicons
* [x] Download
* [x] Fullscreen
* [x] Search in website

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

(C) Copyright by Tim Süberkrüb, 2015
