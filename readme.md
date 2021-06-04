# connect4-mcts
Connect4 using MCTS in Ada. (and Unity)

## Table of Contents
<details>
<summary>Click to expand</summary>

1. [About](#About)
2. [Status](#Status)
3. [Prerequisites](#Prerequisites)  
4. [Dependencies](#Dependencies)
5. [Building](#Building)
   1. [Windows](#Windows)
   2. [Linux](#Linux)
6. [Installation](#Installation)
7. [Limitations](#Limitations)
8. [Usage](#Usage)
9. [Acknowledgments](#Acknowledgments)

</details>

## About
- Connect 4 game skinned by Unity

- AI player is implemented using a MCTS (Monte Carlo Tree Search)

## Status
- Working well. 

## Prerequisites
- GNAT (tested and working with GNAT community 2020)
- Unity (tested and working with 2020+)

## Dependencies
- None

## Building

#### Windows
- Install [GNAT community 2020](https://community.download.adacore.com/v1/966801764ae160828c97d2c33000e9feb08d4cce?filename=gnat-2020-20200429-x86_64-windows-bin.exe)
```
$ git clone https://github.com/ohenley/connect4-mcts   
$ cd connect4-mcts
$ gprbuild connect4.gpr
$ cp ./connect4.dll ./unity/ada_connect/Assets/Plugins
```
- Add the Unity project found at `[root_of_repo]/connect4-mcts/unity/ada_connect` to the Unity Hub. Then open project.

## Installation
Not Applicable.

## Limitations
- Small bug sometime when far in the game, the MCTS does not seem to converge. Probably missing a check for equality of paths ... will check soon.

## Usage
- Press play button in Unity
- Press number keyboard 1-7 to play your turn in corresponding column.

## Acknowledgments
- Thanks to Quentin Ochem for https://github.com/AdaCore/UnityAdaTetris to show the way of Ada over Unity.
- John Levine at University of Strathclyde : https://www.youtube.com/watch?v=UXW2yZndl7U&t=11s for the MCST great explanation.
- Github @vgarciasc : https://github.com/vgarciasc/mcts-viz for its great MCST visualization tool.


