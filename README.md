## MouseDef

<p align="center">
 <img src="https://raw.githubusercontent.com/zenangst/MouseDef/master/Images/MouseDef.png" alt="MouseDef" width="512" align="center" />
</p>

⚠️ This application is in its alpha stage, things may change drastically going forward. ⚠️

MouseDef is a Mac desktop utility that lets you move and resize windows by
holding down modifier keys.

### How it works

MouseDef uses the accessibility features in macOS in order to gain information about the cursor's current position and to resolve which window is underneath the cursor in addition to setting the new position and/or size as the mouse cursor moves.

#### Default keyboard shortcuts are:

- **fn + ⌘** : Move window
- **⇧ + ⌘** : Resize window

### Features

- [ ] Customizable keyboard shortcut keys
- [x] Move windows when modifier keys are active
- [x] Resize windows when modifier keys are active
- [x] Quadrant resizing

### Build and run the project

The project setup uses XcodeGen to generate an Xcode project.
For more detailed instructions about Xcode, please visit their [README.md](https://github.com/yonaskolb/XcodeGen#installing)

```fish
xcodegen
open -a "Xcode" MouseDef.xcodeproj
```

### Contributing

If you want to contribute to making MouseDef the go to a window management tool,
there a multiple ways of contributing.

- When you find a bug, simply file an issue explaining the bug you are facing with detailed steps on how to reproduce it.
- If you want to be next level awesome, you can always make a PR to the project with a fix for the issue and it will be reviewed when life allows.
- If you simply enjoy the product and want to show your general appreciation, you can just give a small shoutout on [Twitter](https://twitter.com/zenangst).

### Credit

A big shout out to [Keith](https://github.com/keith) for open sourcing [ModMove](https://github.com/keith/ModMove) which was a huge inspiration when this application came into fruition.
