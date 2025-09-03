# SPSFbaSync

![Latest release date](https://img.shields.io/github/release-date/luigilink/SPSFbaSync.svg?style=flat)
![Total downloads](https://img.shields.io/github/downloads/luigilink/SPSFbaSync/total.svg?style=flat)  
![Issues opened](https://img.shields.io/github/issues/luigilink/SPSFbaSync.svg?style=flat)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](code_of_conduct.md)

## Description

SPSFbaSync is a PowerShell script to Synchronize user information (email, display name, etc.) from a SQL Membership Provider (Forms Based Authentication) database to SharePoint User Profile Service.

[Download the latest release, Click here!](https://github.com/luigilink/SPSFbaSync/releases/latest)

## Why?

Since SharePoint 2016 introduced **AD Import**, FBA users no longer get their email and other properties synced automatically. This script bridges that gap by pulling data from your ASP.NET Membership database and pushing it into SharePoint.

## Requirements

### Windows Management Framework 5.0

Required because this module now implements class-based resources.
Class-based resources can only work on computers with Windows rManagement Framework 5.0 or above.
The preferred version is PowerShell 5.1 or higher, which ships with Windows 10 or Windows Server 2016.
This is discussed further on the [SPSFbaSync Wiki Getting-Started](https://github.com/luigilink/SPSFbaSync/wiki/Getting-Started)

## Documentation

For detailed usage, configuration, and getting started information, visit the [SPSFbaSync Wiki](https://github.com/luigilink/SPSFbaSync/wiki)

## Changelog

A full list of changes in each version can be found in the [change log](CHANGELOG.md)
