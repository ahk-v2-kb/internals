# Custom Function Object

Requires: [`[v2.0-a108-a2fa0498]`](https://github.com/Lexikos/AutoHotkey_L/releases/tag/v2.0-a108)

Related: [[SUGGEST][AHKv2.0-a108] types](https://www.autohotkey.com/boards/viewtopic.php?p=309928#p309928)

## Objective

Define a custom function object, mimicking the interface of built-in `Func` and `BoundFunc` objects.

## Problem

A class-based function object lacks the built-in properties and methods that come bundled with standard `Func` and `BoundFunc` objects out of the box. Examples include, among others, `Name`, `MaxParams`, `IsVariadic`, `Bind()`, `IsByRef()` and so on.

It is as of yet (`[v2.0-a108-a2fa0498]`) impossible to `extend` the `Func` and `BoundFunc` interfaces, so as to be able to inherit the missing properties and methods automatically. Thus, for a class-based function object to be seemlessly interchangable with function objects derived from `Func` and `BoundFunc` (and `Closure`), the burden falls on the end-user to reimplement any parts missing from the interface.

The extendable base class `FuncObjBase` aims to rectify this.

## Caveats

Function objects that base their implementation on meta `__Call()` were not handled, on account of meta-function implementations being [discouraged](https://www.autohotkey.com/v2/v2-changes.htm). Prefer regular `Call()` instance methods instead.